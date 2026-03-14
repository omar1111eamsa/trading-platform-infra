# Infra

Infrastructure code for the test deployment of the trading platform on Google Cloud.

This folder contains:

- `ansible/`: VM preparation and app bootstrap automation
- `terraform/`: Google Cloud infrastructure definitions
- `docs/`: deployment runbooks and required secrets

Current target environment:

- `frontend-vm` at `REDACTED_IP`
- `backend-vm` at `REDACTED_IP`
- project: `ethereal-aria-490011-s9`
- zone: `europe-west1-b`

Quick start:

```bash
cd infra/ansible
ansible-galaxy collection install -r collections/requirements.yml
ansible-playbook -i inventories/test/hosts.yml playbooks/site.yml
```

Terraform quick start:

```bash
cd infra/terraform
terraform init
cp terraform.tfvars.example terraform.tfvars
terraform validate
terraform plan
```

Before running Ansible, review:

- `ansible/inventories/test/group_vars/all.yml`
- `ansible/inventories/test/host_vars/frontend-vm.yml`
- `ansible/inventories/test/host_vars/backend-vm.yml`
- `docs/runbook.md`

Before running Terraform, review:

- `terraform/main.tf`
- `terraform/variables.tf`
- `terraform/terraform.tfvars.example`
- `terraform/README.md`
