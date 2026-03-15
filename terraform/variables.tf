variable "project_id" {
  description = "Google Cloud project ID."
  type        = string
  default     = "ethereal-aria-490011-s9"
}

variable "region" {
  description = "Google Cloud region."
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Google Cloud zone."
  type        = string
  default     = "europe-west1-b"
}

variable "network" {
  description = "VPC network name."
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "Subnetwork name."
  type        = string
  default     = "default"
}

variable "image_project" {
  description = "Boot image project."
  type        = string
  default     = "ubuntu-os-cloud"
}

variable "image_family" {
  description = "Boot image family."
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "windows_image_project" {
  description = "Boot image project for the Windows VM."
  type        = string
  default     = "windows-cloud"
}

variable "windows_image_family" {
  description = "Boot image family for the Windows VM."
  type        = string
  default     = "windows-2022"
}

variable "frontend_vm_name" {
  description = "Frontend instance name."
  type        = string
  default     = "frontend-vm"
}

variable "backend_vm_name" {
  description = "Backend instance name."
  type        = string
  default     = "backend-vm"
}

variable "windows_vm_name" {
  description = "Windows instance name."
  type        = string
  default     = "windows-vm"
}

variable "frontend_machine_type" {
  description = "Machine type for the frontend VM."
  type        = string
  default     = "e2-highcpu-2"
}

variable "backend_machine_type" {
  description = "Machine type for the backend VM."
  type        = string
  default     = "e2-custom-2-4096"
}

variable "windows_machine_type" {
  description = "Machine type for the Windows VM."
  type        = string
  default     = "e2-custom-4-8192"
}

variable "frontend_disk_size_gb" {
  description = "Boot disk size for the frontend VM."
  type        = number
  default     = 10
}

variable "backend_disk_size_gb" {
  description = "Boot disk size for the backend VM."
  type        = number
  default     = 15
}

variable "windows_disk_size_gb" {
  description = "Boot disk size for the Windows VM."
  type        = number
  default     = 50
}

variable "frontend_tags" {
  description = "Network tags for the frontend VM."
  type        = list(string)
  default     = ["frontend-vm", "http-server"]
}

variable "backend_tags" {
  description = "Network tags for the backend VM."
  type        = list(string)
  default     = ["backend-vm"]
}

variable "windows_tags" {
  description = "Network tags for the Windows VM."
  type        = list(string)
  default     = ["windows-vm", "rdp-server"]
}

variable "ssh_source_ranges" {
  description = "Allowed source ranges for SSH to the Linux VMs."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "rdp_source_ranges" {
  description = "Allowed source ranges for RDP to the Windows VM."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "windows_admin_user" {
  description = "Primary local administrator username to create on the Windows VM."
  type        = string
  default     = "hodeconlimited"
}

variable "windows_admin_password" {
  description = "Password for the Windows local administrator account created by the startup script."
  type        = string
  sensitive   = true
  default     = "ChangeMe123!ChangeMe123!"
}

variable "frontend_domain_name" {
  description = "Frontend DNS name to point at the frontend static IP."
  type        = string
  default     = "dashboardt.example.com."
}

variable "frontend_dns_managed_zone" {
  description = "Cloud DNS managed zone name for the frontend domain. Leave empty if DNS is managed elsewhere."
  type        = string
  default     = ""
}

variable "create_frontend_dns_record" {
  description = "Whether to manage the frontend A record in Cloud DNS."
  type        = bool
  default     = false
}

variable "frontend_dns_ttl" {
  description = "TTL for the frontend DNS A record."
  type        = number
  default     = 300
}

variable "windows_instance_count" {
  description = "Number of Windows VM instances to create."
  type        = number
  default     = 1
}
