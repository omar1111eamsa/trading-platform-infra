# Root domain A record
resource "ovh_domain_zone_record" "root" {
  zone      = var.domain
  fieldtype = "A"
  ttl       = 300
  target    = ovh_cloud_project_instance.app_vps.ip_address
}

# API subdomain
resource "ovh_domain_zone_record" "api" {
  zone      = var.domain
  subdomain = "api"
  fieldtype = "A"
  ttl       = 300
  target    = ovh_cloud_project_instance.app_vps.ip_address
}

# Terminal subdomain
resource "ovh_domain_zone_record" "terminal" {
  zone      = var.domain
  subdomain = "terminal"
  fieldtype = "A"
  ttl       = 300
  target    = ovh_cloud_project_instance.app_vps.ip_address
}

# Dashboard subdomain
resource "ovh_domain_zone_record" "dashboard" {
  zone      = var.domain
  subdomain = "dashboard"
  fieldtype = "A"
  ttl       = 300
  target    = ovh_cloud_project_instance.app_vps.ip_address
}

# Staging subdomains
resource "ovh_domain_zone_record" "staging_api" {
  zone      = var.domain
  subdomain = "staging-api"
  fieldtype = "A"
  ttl       = 300
  target    = ovh_cloud_project_instance.app_vps.ip_address
}

resource "ovh_domain_zone_record" "staging_terminal" {
  zone      = var.domain
  subdomain = "staging-terminal"
  fieldtype = "A"
  ttl       = 300
  target    = ovh_cloud_project_instance.app_vps.ip_address
}

resource "ovh_domain_zone_record" "staging_dashboard" {
  zone      = var.domain
  subdomain = "staging-dashboard"
  fieldtype = "A"
  ttl       = 300
  target    = ovh_cloud_project_instance.app_vps.ip_address
}
