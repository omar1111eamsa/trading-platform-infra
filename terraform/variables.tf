variable "region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-1"
}

variable "availability_zone" {
  description = "AWS availability zone."
  type        = string
  default     = "eu-west-1a"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

# ── SSH / RDP access ──

variable "ssh_key_name" {
  description = "Base name for the Terraform-managed RSA key pair in EC2 (actual key name will be \"<name>-rsa\"). Private PEM is written to terraform/generated/ec2_rsa.pem."
  type        = string
}

variable "linux_ssh_user" {
  description = "First-boot SSH user on the Ubuntu AMI (EC2 Canonical images use ubuntu)."
  type        = string
  default     = "ubuntu"
}

variable "ansible_ssh_private_key_path" {
  description = "Path to the private key Ansible and the optional provisioner should use (expanded with pathexpand). Empty = rely on ssh-agent."
  type        = string
  default     = ""
}

variable "ansible_provision" {
  description = "If true, run ansible-playbook against the Linux VM after Terraform apply (requires ansible on PATH and a reachable key or agent)."
  type        = bool
  default     = false
}

variable "ansible_playbook_relative_dir" {
  description = "Directory containing the Ansible playbooks, relative to the terraform module path (default: sibling ../ansible)."
  type        = string
  default     = "../ansible"
}

variable "ssh_source_ranges" {
  description = "Allowed source CIDRs for SSH."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "rdp_source_ranges" {
  description = "Allowed source CIDRs for RDP."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ── Linux VM (backend + frontends) ──

variable "linux_vm_name" {
  description = "Name tag for the Linux VM."
  type        = string
  default     = "trading-platform-vm"
}

variable "linux_instance_type" {
  description = "EC2 instance type for the Linux VM."
  type        = string
  default     = "t3.large"
}

variable "linux_disk_size_gb" {
  description = "Root volume size for the Linux VM in GB."
  type        = number
  default     = 80
}

variable "linux_ami_owner" {
  description = "AMI owner for Ubuntu images (Canonical)."
  type        = string
  default     = "099720109477"
}

variable "linux_ami_name_filter" {
  description = "AMI name filter for Ubuntu 22.04."
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}

# ── Windows VM (MT5 worker) ──

variable "windows_vm_name" {
  description = "Name tag for the Windows VM."
  type        = string
  default     = "mt5-worker-vm"
}

variable "windows_instance_type" {
  description = "EC2 instance type for the Windows VM."
  type        = string
  default     = "t3.large"
}

variable "windows_disk_size_gb" {
  description = "Root volume size for the Windows VM in GB."
  type        = number
  default     = 50
}

variable "windows_instance_count" {
  description = "Number of Windows MT5 VMs to create."
  type        = number
  default     = 1
}

variable "windows_admin_user" {
  description = "Admin username for the Windows VM."
  type        = string
  default     = "hodeconlimited"
}

variable "windows_admin_password" {
  description = "Admin password for the Windows VM."
  type        = string
  sensitive   = true
}

# ── Domain names (informational, DNS managed externally) ──

variable "frontend_domain_name" {
  description = "Frontend domain name (dashboard)."
  type        = string
  default     = "dashboard.example.com"
}

variable "backend_domain_name" {
  description = "Backend domain name (API)."
  type        = string
  default     = "api.example.com"
}

variable "terminal_domain_name" {
  description = "UI-Terminal domain name."
  type        = string
  default     = "terminal.example.com"
}

# ── Tags ──

variable "common_tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default = {
    environment = "test"
    managed_by  = "terraform"
    project     = "stage-tradingplatform"
  }
}
