# Terraform

Terraform for Google Cloud resources used by the test environment.

Managed resources:

- `frontend-vm`
- `backend-vm`
- `allow-frontend-http`
- `allow-frontend-monitoring`
- `allow-backend-8081`

Current design:

- project: `ethereal-aria-490011-s9`
- network: `default`
- zone: `europe-west1-b`
- frontend VM has an ephemeral external IP and serves HTTP on port `80`
- backend VM has an ephemeral external IP and serves the API on port `8081`

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
cd infra/terraform
terraform init
cp terraform.tfvars.example terraform.tfvars
terraform validate
```

## Import the existing VMs and firewall rules

These resources already exist in GCP. Import them before relying on `terraform plan` output.

```bash
terraform import google_compute_instance.frontend_v1 projects/ethereal-aria-490011-s9/zones/europe-west1-b/instances/frontend-vm
terraform import google_compute_instance.backend_v1 projects/ethereal-aria-490011-s9/zones/europe-west1-b/instances/backend-vm
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

- External IPs are ephemeral by design here.
- The frontend VM currently maps best to `e2-highcpu-2`, which is what GCP created.
- The backend VM is `e2-custom-2-4096`.
- Monitoring UI is published on `frontend-vm:3001` for the test environment.
