# Root domain
resource "ovh_domain_zone_record" "root" {
  zone      = var.domain
  fieldtype = "A"
  ttl       = var.dns_ttl
  target    = var.vps_ip
}

# Production records
resource "ovh_domain_zone_record" "api" {
  zone      = var.domain
  subdomain = "api"
  fieldtype = "A"
  ttl       = var.dns_ttl
  target    = var.vps_ip
}

resource "ovh_domain_zone_record" "terminal" {
  zone      = var.domain
  subdomain = "terminal"
  fieldtype = "A"
  ttl       = var.dns_ttl
  target    = var.vps_ip
}

resource "ovh_domain_zone_record" "dashboard" {
  zone      = var.domain
  subdomain = "dashboard"
  fieldtype = "A"
  ttl       = var.dns_ttl
  target    = var.vps_ip
}

# Staging records
resource "ovh_domain_zone_record" "staging_api" {
  zone      = var.domain
  subdomain = "staging-api"
  fieldtype = "A"
  ttl       = var.dns_ttl
  target    = var.vps_ip
}

resource "ovh_domain_zone_record" "staging_terminal" {
  zone      = var.domain
  subdomain = "staging-terminal"
  fieldtype = "A"
  ttl       = var.dns_ttl
  target    = var.vps_ip
}

resource "ovh_domain_zone_record" "staging_dashboard" {
  zone      = var.domain
  subdomain = "staging-dashboard"
  fieldtype = "A"
  ttl       = var.dns_ttl
  target    = var.vps_ip
}

# ArgoCD UI
resource "ovh_domain_zone_record" "argocd" {
  zone      = var.domain
  subdomain = "argocd"
  fieldtype = "A"
  ttl       = var.dns_ttl
  target    = var.vps_ip
}

# Grafana UI
resource "ovh_domain_zone_record" "grafana" {
  zone      = var.domain
  subdomain = "grafana"
  fieldtype = "A"
  ttl       = var.dns_ttl
  target    = var.vps_ip
}
