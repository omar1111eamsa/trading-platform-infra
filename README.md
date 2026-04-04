# SysteM Infrastructure

Infrastructure code for the trading platform (Ansible + Terraform). Terraform targets **AWS**; Ansible supports any Linux host with the same layout.

This folder contains:

- `ansible/`: VM preparation and app bootstrap automation
- `terraform/`: AWS infrastructure definitions
- `monitoring/`: runtime monitoring assets managed through Ansible
- `docs/`: deployment runbooks and required secrets

Naming matches **Terraform** (`aws_instance.linux_vm`, variable `linux_vm_name`, default `trading-platform-vm`):

- **Ansible groups** `linux_ui` and `linux_api` — two logical targets on the **same** Linux EC2 instance (terminal UI vs API + nginx).
- **Inventory host names** `{{ linux_vm_name }}-ui` and `{{ linux_vm_name }}-api` (e.g. `trading-platform-vm-ui`, `trading-platform-vm-api`) — these appear in Ansible logs and GitHub runner names.
- **Windows MT5** worker: Terraform `aws_instance.windows_vm` / variable `windows_vm_name` (default `mt5-worker-vm`).

Legacy GCP example IPs (historical):

- Linux workloads previously split across two GCE VMs; AWS consolidates them on one `linux_vm`.
- `windows-vm` at `REDACTED_IP` (existing manual MT5 host)
- `windows-vm-2` at `REDACTED_IP` (existing manual clone/standby)
- `uptime-kuma` at `http://REDACTED_IP:3001`
- frontend domain target: `dashboard.example.com`
- backend domain target: `api.example.com`
- project: `ethereal-aria-490011-s9`
- zone: `europe-west1-b`

Runner plan (same Linux box, two runners):

- **`{{ linux_vm_name }}-ui`** — UI-Terminal- / terminal-dashboard deploy jobs
- **`{{ linux_vm_name }}-api`** — Terminal-backend deploy jobs

Quick start (AWS, single Linux VM for backend + frontends):

```bash
cd terraform
terraform init
cp terraform.tfvars.example terraform.tfvars   # edit ssh_key_name, keys, passwords
terraform apply
# Writes ansible/inventories/aws/hosts.generated.yml (gitignored) with the Elastic IP

cd ../ansible
ansible-galaxy collection install -r collections/requirements.yml
ansible-playbook -i inventories/test/hosts.yml -i inventories/aws/hosts.generated.yml playbooks/site.yml
```

Optional: set `ansible_provision = true` in `terraform.tfvars` to run the same playbook automatically after apply (requires `ansible` on the machine running Terraform).

Self-hosted GitHub Actions (three repo-scoped runners on one VM — no org admin required):

- **`linux_ui` play** registers a runner for **UI-Terminal-** (`{{ linux_vm_name }}-ui`, label `trading-platform-vm-ui`).
- **`linux_api` play** registers a runner for **Terminal-backend** (`{{ linux_vm_name }}-api`, label `trading-platform-vm-api`).
- **`linux_dashboard` play** registers a runner for **terminal-dashboard** (`{{ linux_vm_name }}-dashboard`, same label **`trading-platform-vm-ui`** so existing dashboard workflows match).
- **Tokens** (each repo → Settings → Actions → Runners → New self-hosted runner): put in `secrets.local.yml` or vault as `frontend_github_runner_registration_token`, `backend_github_runner_registration_token`, and `terminal_dashboard_github_runner_registration_token`. You can also pass them with `-e` for a one-off run.
- Add each runner’s SSH public key to `deploy_ssh_public_keys` in secrets when GitHub shows it during registration (three keys total over time).
- **Org runner cleanup:** If you previously used `trading-platform-vm-org`, delete that runner in GitHub and on the VM remove `/opt/github-actions-runner/trading-platform-vm-org`, or set `github_runner_cleanup_legacy: ['{{ linux_vm_name }}-org']` once under `linux_ui` group vars.
- Repo secrets `BACKEND_APP_DIR` and `UI_TERMINAL_APP_DIR` stay pointed at `/opt/apps/Terminal-backend` and `/opt/apps/UI-Terminal-` on the Linux VM.

**Domains (no `:8081` in the browser):** Point `api` and `terminal` hostnames at the Linux VM IP, then run Ansible. The `nginx_edge` role proxies `http(s)://api.<domain>/` → `127.0.0.1:8081` and `terminal.<domain>` → UI on `:3000`, with WebSocket upgrade on `/ws`. Defaults use `public_url_scheme: http`; after DNS works, set `nginx_edge_letsencrypt: true`, `certbot_admin_email`, re-run the playbook, then set `public_url_scheme: https` and re-run once more so app `.env` files get `https`/`wss`. Refresh GitHub secret `UI_TERMINAL_DOTENV` if the UI repo builds from that secret.

Manual / split-VM inventory (edit host IPs first):

```bash
cd ansible
ansible-galaxy collection install -r collections/requirements.yml
ansible-playbook -i inventories/test/hosts.yml playbooks/site.yml
```

Terraform quick start:

```bash
cd terraform
terraform init
cp terraform.tfvars.example terraform.tfvars
terraform validate
terraform plan
```

Before running Ansible, review:

- `ansible/inventories/test/group_vars/all.yml` (includes `linux_vm_name`, must match Terraform)
- `ansible/inventories/test/group_vars/linux_ui.yml` and `linux_api.yml`
- `ansible/inventories/test/group_vars/secrets.vault.yml` as the tracked encrypted secret file
- `ansible/inventories/test/group_vars/secrets.local.yml` only as a temporary fallback
- `docs/runbook.md`

Linux SSH model:

- first connection on EC2 Ubuntu: `ubuntu` (`bootstrap_ansible_user` in `group_vars/all.yml`)
- managed application admin account created on the VM: `hodeconlimited` (`admin_user`)
- On **GCP or custom images** where you SSH only as `hodeconlimited`, set `bootstrap_ansible_user: hodeconlimited` in `secrets.local.yml` (or another vars file you include)

Before running Terraform, review:

- `terraform/main.tf`
- `terraform/variables.tf`
- `terraform/terraform.tfvars.example`
- `terraform/README.md`

Windows worker model:

- the current `windows-vm` and `windows-vm-2` are preserved as existing manual MT5 hosts
- future production MT5 worker VMs should be created from the `mt5-worker-golden` custom image
- Terraform worker creation is defined but disabled by default until you explicitly opt in
