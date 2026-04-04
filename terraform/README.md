# Terraform

**Primary path:** `main.tf` defines **AWS** resources — `aws_instance.linux_vm` (Name tag from `linux_vm_name`, default `trading-platform-vm`), Elastic IP, security groups, and `aws_instance.windows_vm` for MT5 (`windows_vm_name`, default `mt5-worker-vm`). Ansible inventory generated from the template uses host names `{{ linux_vm_name }}-ui` and `{{ linux_vm_name }}-api` on the same Linux IP.

Legacy Google Cloud notes below apply only if you still maintain that state.

Managed resources (historical GCP doc — instance names were `frontend-vm` / `backend-vm`):

- `frontend-vm` (legacy GCE)
- `backend-vm` (legacy GCE)
- `frontend-vm` static public IP
- `backend-vm` static public IP
- optional future `mt5-worker` VMs created from a golden image
- optional future `mt5-worker` static public IPs
- `allow-stage-vm-ssh`
- `allow-frontend-http`
- `allow-frontend-monitoring`
- `allow-backend-8081`
- `allow-windows-rdp`
- optional Cloud DNS A records for `dashboard.example.com.` and `api.example.com.`

Current design:

- project: `ethereal-aria-490011-s9`
- network: `default`
- zone: `europe-west1-b`
- frontend VM uses a static external IP and serves HTTP on port `80`
- backend VM uses a static external IP and serves the API on port `8081`
- existing `windows-vm` and `windows-vm-2` remain manual MT5 hosts and are not part of the desired apply path
- future MT5 workers use `e2-custom-4-8192` by default, boot from the `mt5-worker-golden` custom image, and allow RDP/WinRM
- all core VMs and future workers stay on the same `default` VPC/subnet
- frontend static IP currently resolves to `REDACTED_IP`
- current manual Windows host IPs are `REDACTED_IP` and `REDACTED_IP`

## Files

- `versions.tf`: Terraform and provider requirements
- `providers.tf`: Google provider config
- `variables.tf`: input variables
- `main.tf`: VM and firewall definitions
- `outputs.tf`: instance IP outputs
- `.terraform.lock.hcl`: provider lock file that should be committed
- `terraform.tfvars.example`: sample values

## Initialize

```bash
cd terraform
terraform init
cp terraform.tfvars.example terraform.tfvars
terraform validate
```

## Import the existing core VMs and firewall rules

These resources already exist in GCP. Import them before relying on `terraform plan` output.

```bash
terraform import google_compute_instance.frontend_v1 projects/ethereal-aria-490011-s9/zones/europe-west1-b/instances/frontend-vm
terraform import google_compute_instance.backend_v1 projects/ethereal-aria-490011-s9/zones/europe-west1-b/instances/backend-vm
terraform import google_compute_firewall.linux_vm_ssh projects/ethereal-aria-490011-s9/global/firewalls/allow-stage-vm-ssh
terraform import google_compute_firewall.frontend_http projects/ethereal-aria-490011-s9/global/firewalls/allow-frontend-http
terraform import google_compute_firewall.frontend_monitoring projects/ethereal-aria-490011-s9/global/firewalls/allow-frontend-monitoring
terraform import google_compute_firewall.backend_api projects/ethereal-aria-490011-s9/global/firewalls/allow-backend-8081
```

Then run:

```bash
terraform fmt
terraform plan
```

## Notes

- The frontend VM currently maps best to `e2-highcpu-2`, which is what GCP created.
- The backend VM is `e2-custom-4-8192`.
- The future MT5 worker default is `e2-custom-4-8192`.
- The `mt5-worker` resources are disabled by default via `create_mt5_workers = false`.
- The worker image reference should stay on the golden image family, for example `projects/ethereal-aria-490011-s9/global/images/family/mt5-worker-golden`.
- Monitoring UI is published on port `3001` on the Linux host (Ansible `linux_ui`; default runner host name `trading-platform-vm-ui`).
- The optional DNS records require Cloud DNS to be enabled and a managed zone for `example.com` to exist in this project.
- If DNS is managed outside GCP, leave `create_frontend_dns_record = false` and `create_backend_dns_record = false`, then create external A records pointing to the Terraform frontend and backend static IP outputs.
- `windows_admin_password` is marked sensitive, but it still lands in Terraform state and instance metadata because the Windows user is created by startup script. Treat that value as a bootstrap secret and rotate it after first login.
- The current frontend domain target should point to `REDACTED_IP`.
- The backend domain target should point to the Terraform `backend_external_ip` output.
