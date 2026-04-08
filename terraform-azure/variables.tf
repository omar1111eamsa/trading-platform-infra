variable "location" {
  description = "Azure region (e.g. westeurope, francecentral)."
  type        = string
  default     = "westeurope"
}

variable "prefix" {
  description = "Short name prefix for resources (letters, numbers, hyphens)."
  type        = string
  default     = "trading-stage"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.42.0.0/16"]
}

variable "subnet_cidr" {
  description = "CIDR for the workload subnet (Windows VM)."
  type        = string
  default     = "10.42.1.0/24"
}

# ── Access control ──

variable "rdp_source_ranges" {
  description = <<-EOT
    Source prefixes allowed to RDP (TCP 3389) to the Windows VM.
    Use specific /32 CIDRs for least exposure, or Azure keyword "Internet" to allow any public client
    (relies on a strong windows_admin_password; expect brute-force noise).
  EOT
  type = list(string)

  validation {
    condition     = length(var.rdp_source_ranges) > 0
    error_message = "rdp_source_ranges must be non-empty."
  }
}

# ── Windows VM (MT5) ──

variable "windows_vm_size" {
  description = "Azure VM size for Windows / MT5. B-series may hit capacity limits in some regions; D2s_v5 is a reliable default."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "windows_admin_username" {
  type    = string
  default = "azureuser"
}

variable "windows_admin_password" {
  description = "Windows admin password (min length/complexity per Azure policy)."
  type        = string
  sensitive   = true
}

variable "windows_os_disk_gb" {
  type    = number
  default = 128
}

variable "common_tags" {
  type        = map(string)
  description = "Tags applied to supported resources."
  default     = {}
}
