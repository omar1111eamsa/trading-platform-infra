# OVH API credentials
variable "ovh_endpoint" {
  description = "OVH API endpoint"
  type        = string
  default     = "ovh-eu"
}

variable "ovh_application_key" {
  description = "OVH application key"
  type        = string
  sensitive   = true
}

variable "ovh_application_secret" {
  description = "OVH application secret"
  type        = string
  sensitive   = true
}

variable "ovh_consumer_key" {
  description = "OVH consumer key"
  type        = string
  sensitive   = true
}

variable "ovh_service_name" {
  description = "OVH public cloud project ID"
  type        = string
}

# VPS config
variable "region" {
  description = "OVH region"
  type        = string
  default     = "GRA11"
}

variable "vps_name" {
  description = "Name of the VPS instance"
  type        = string
  default     = "platform-vps"
}

variable "vps_flavor" {
  description = "OVH instance flavor"
  type        = string
  default     = "b3-8"
}

variable "vps_image" {
  description = "OS image"
  type        = string
  default     = "Ubuntu 22.04"
}

variable "ssh_public_key" {
  description = "SSH public key for VPS access"
  type        = string
}

# Domain
variable "domain" {
  description = "Root domain"
  type        = string
  default     = "example.com"
}
