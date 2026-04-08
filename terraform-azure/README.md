# Azure Terraform (Windows VM only)

This directory provisions a **single Windows VM** on **Microsoft Azure** for MT5 (RDP access). It does not manage Linux or application infrastructure.

## What gets created

| Resource | Purpose |
|----------|---------|
| Resource group | Container for all resources |
| VNet `10.42.0.0/16` + subnet | Network for the Windows VM |
| **Windows VM** (default `Standard_D2s_v5`) | Windows Server 2022 Datacenter (MT5 / RDP) |
| Windows NSG | RDP (3389) inbound from `rdp_source_ranges` |
| Public IP | Static Standard SKU |

## Prerequisites

1. Azure subscription.
2. Azure CLI: `az login` and select the right subscription (`az account set --subscription <id>`).
3. Terraform `>= 1.5`.

## Quick start

```bash
cd SysteM/terraform-azure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars:
# - set rdp_source_ranges to your public IP /32 or "Internet"
# - set a strong windows_admin_password

terraform init
terraform plan
terraform apply
```

After apply:

```bash
terraform output -raw windows_public_ip
terraform output rdp_command
```

## IPs without Terraform

After `az login`, list addresses for the stack’s resource group:

```bash
az vm list-ip-addresses -g "$(terraform output -raw resource_group_name)" -o table
# or, if you know the name:
az vm list-ip-addresses -g trading-stage-rg -o table
```

## Destroy when done

```bash
terraform destroy
```

Removes the Windows VM, IP, VNet, and NSG. Back up anything you need before destroy.
