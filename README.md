# System Infrastructure

Infrastructure code for the trading platform.

Current production/stage model:
- OVH VPS for API, terminal UI, and dashboard deployments (via Ansible)
- Azure Terraform kept only for optional Windows VM provisioning (MT5)

## Folder Layout

- `ansible/`: host bootstrap, app runtime config, and GitHub self-hosted runners
- `docs/`: operational and architecture documentation
- `monitoring/`: Uptime Kuma assets used by Ansible
- `terraform-azure/`: Azure Terraform stack (Windows VM only)

## Ansible Runtime Model (OVH)

Ansible inventory groups map to logical services on the same VPS:
- `linux_api` -> backend (`stable-backend-`) + Nginx Edge Proxy (Reverse proxy mapped via `/etc/nginx/sites-enabled/app-edge.conf` processing Let's Encrypt SSL/TLS certificates)
- `linux_ui` -> terminal frontend (`UI-Terminal-`) + monitoring
- `linux_dashboard` -> admin dashboard (`terminal-dashboard`)

Runner labels expected by CI:
- `trading-platform-vm-api`
- `trading-platform-vm-ui`
- `trading-platform-vm-dashboard`

## Quick Start (OVH)

```bash
cd ansible
ansible-galaxy collection install -r collections/requirements.yml
./scripts/deploy-ovh.sh
```

Before deploying:
- set OVH host IP(s) in `ansible/inventories/ovh/hosts.yml`
- set secrets in `ansible/inventories/ovh/group_vars/secrets.local.yml` or vault

## Documentation Map

- Operations runbook: `docs/operations/ovh-runbook.md`
- Project status: `docs/status/project-status.md`
- MT5 scaling design: `docs/architecture/mt5-worker-scaling.md`

## Azure Terraform (Windows Only)

`terraform-azure/` provisions one Windows VM plus networking and RDP access rules.
See `terraform-azure/README.md`.
