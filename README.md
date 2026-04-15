# System Infrastructure

Infrastructure code for the trading platform.

Current production/stage model:
- Linux VMs deploying via 100% portable Centralized Docker Compose Orchestration (Managed by Watchtower)
- Azure Terraform kept only for optional Windows VM provisioning (MT5)

## Folder Layout

- `ansible/`: host bootstrap and configuration transfer
- `docs/`: operational and architecture documentation
- `monitoring/`: Uptime Kuma assets used by Ansible
- `terraform-azure/`: Azure Terraform stack (Windows VM only)
- `docker-compose.yml`: Master orchestration running all databases, frontends, backends, and Watchtower natively.

## Ansible Runtime Model

Ansible no longer manages continuous application deployment or GitHub Runner agents. It is purely used to securely push `.env` configurations and copy the `docker-compose.yml` file to the VM, acting as an immutable infrastructure provisioner. All application deployments are handled instantly by **Watchtower**.

## Quick Start

```bash
cd ansible
ansible-galaxy collection install -r collections/requirements.yml
./scripts/deploy-ovh.sh
```

Before deploying:
- Configure target VMs in `ansible/inventories/ovh/hosts.yml` (or your preferred environment)
- Set secrets in `ansible/inventories/ovh/group_vars/secrets.local.yml` or vault

## Documentation Map

- Operations runbook: `docs/operations/ovh-runbook.md`
- Project status: `docs/status/project-status.md`
- MT5 scaling design: `docs/architecture/mt5-worker-scaling.md`

## Azure Terraform (Windows Only)

`terraform-azure/` provisions one Windows VM plus networking and RDP access rules.
See `terraform-azure/README.md`.
