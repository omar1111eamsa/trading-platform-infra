# SysteM Infrastructure

Infrastructure code for the test deployment of the trading platform on Google Cloud.

This folder contains:

- `ansible/`: VM preparation and app bootstrap automation
- `terraform/`: Google Cloud infrastructure definitions
- `monitoring/`: runtime monitoring assets managed through Ansible
- `docs/`: deployment runbooks and required secrets

Current target environment:

- `frontend-vm` at `REDACTED_IP`
- `backend-vm` at `REDACTED_IP`
- `windows-vm` at `REDACTED_IP` (existing manual MT5 host)
- `windows-vm-2` at `REDACTED_IP` (existing manual clone/standby)
- `uptime-kuma` at `http://REDACTED_IP:3001`
- frontend domain target: `dashboard.example.com`
- backend domain target: `api.example.com`
- project: `ethereal-aria-490011-s9`
- zone: `europe-west1-b`

Runner plan:

- `frontend-vm` will host the `terminal-dashboard` self-hosted GitHub runner
- `backend-vm` will host the `Terminal-backend` self-hosted GitHub runner

Quick start:

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

- `ansible/inventories/test/group_vars/all.yml`
- `ansible/inventories/test/group_vars/secrets.vault.yml` as the tracked encrypted secret file
- `ansible/inventories/test/group_vars/secrets.local.yml` only as a temporary fallback
- `ansible/inventories/test/host_vars/frontend-vm.yml`
- `ansible/inventories/test/host_vars/backend-vm.yml`
- `docs/runbook.md`

Linux admin user model:

- managed admin user: `hodeconlimited`
- active Linux admin SSH user: `hodeconlimited`
- current verified SSH key path example: `~/.ssh/google_compute_engine`

Before running Terraform, review:

- `terraform/main.tf`
- `terraform/variables.tf`
- `terraform/terraform.tfvars.example`
- `terraform/README.md`

Windows worker model:

- the current `windows-vm` and `windows-vm-2` are preserved as existing manual MT5 hosts
- future production MT5 worker VMs should be created from the `mt5-worker-golden` custom image
- Terraform worker creation is defined but disabled by default until you explicitly opt in
