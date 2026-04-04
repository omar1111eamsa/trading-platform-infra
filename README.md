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

Self-hosted GitHub Actions (organization runner, one VM):

- **One org-level runner** is installed by the `linux_ui` play: `github_runner_organization: Trading-Terminal2025`, name `{{ linux_vm_name }}-org` (e.g. `trading-platform-vm-org`), labels **`trading-platform-vm-ui`**, **`trading-platform-vm-api`**, and `stage-tradingplatform`. It can run deploy jobs for **UI-Terminal-**, **terminal-dashboard**, and **Terminal-backend** as long as GitHub allows it (see below).
- **GitHub UI (required once):** Organization **Trading-Terminal2025** → **Settings** → **Actions** → **Runner groups** → open the group that contains your self-hosted runners (often **Default**) → **Repository access** → **All repositories** or explicitly add `UI-Terminal-`, `terminal-dashboard`, and `Terminal-backend`.
- **Token:** Add `github_org_runner_registration_token` to `secrets.local.yml` or vault. Generate with an org admin account, e.g. `gh api -X POST orgs/Trading-Terminal2025/actions/runners/registration-token -q .token` (needs permission to manage org runners). Run `ansible-playbook ...` with that secret loaded; you can also pass `-e github_org_runner_registration_token=...` for a one-off.
- **`linux_api` play** has `github_runner_enabled: false` so a second runner is not registered for the same host.
- **One-time migration:** `linux_ui.yml` lists `github_runner_cleanup_legacy` for the old per-repo runner directories (`trading-platform-vm-ui`, `trading-platform-vm-api`). After a successful run, remove that list (or set to `[]`). Delete any duplicate **offline** runners under **Organization → Settings → Actions → Runners** if they remain.
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
