# Terraform

Terraform for Google Cloud resources used by the test environment.

Managed resources:

- `frontend-vm`
- `backend-vm`
- `windows-vm`
- `frontend-vm` static public IP
- `windows-vm` static public IP
- `allow-stage-vm-ssh`
- `allow-frontend-http`
- `allow-frontend-monitoring`
- `allow-backend-8081`
- `allow-windows-rdp`
- optional Cloud DNS A record for `dashboardt.example.com.`

Current design:

- project: `ethereal-aria-490011-s9`
- network: `default`
- zone: `europe-west1-b`
- frontend VM uses a static external IP and serves HTTP on port `80`
- backend VM has an ephemeral external IP and serves the API on port `8081`
- windows VM uses `e2-custom-4-8192`, gets a static external IP, and allows RDP on `3389`
- all three VMs stay on the same `default` VPC/subnet
- frontend static IP currently resolves to `REDACTED_IP`
- windows static IP currently resolves to `REDACTED_IP`

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

## Import the existing VMs and firewall rules

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
- The backend VM is `e2-custom-2-4096`.
- The Windows VM is defined as `e2-custom-4-8192`.
- Monitoring UI is published on `frontend-vm:3001` for the test environment.
- The optional DNS record requires Cloud DNS to be enabled and a managed zone for `example.com` to exist in this project.
- If DNS is managed outside GCP, leave `create_frontend_dns_record = false` and create an external A record pointing to the Terraform frontend static IP output.
- `windows_admin_password` is marked sensitive, but it still lands in Terraform state and instance metadata because the Windows user is created by startup script. Treat that value as a bootstrap secret and rotate it after first login.
- The current frontend domain target should point to `REDACTED_IP`.
