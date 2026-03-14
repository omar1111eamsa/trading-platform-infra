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

variable "ssh_source_ranges" {
  description = "Allowed source ranges for SSH if you later manage SSH rules here."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
