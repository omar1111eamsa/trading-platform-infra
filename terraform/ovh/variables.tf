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

variable "vps_ip" {
  description = "Existing VPS public IP"
  type        = string
  default     = "REDACTED_VPS_IP"
}

variable "domain" {
  description = "Root domain"
  type        = string
  default     = "example.com"
}

variable "dns_ttl" {
  description = "DNS record TTL in seconds"
  type        = number
  default     = 300
}
