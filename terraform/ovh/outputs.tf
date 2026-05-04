output "dns_records" {
  description = "All DNS records created"
  value = {
    root              = "${var.domain} -> ${var.vps_ip}"
    api               = "api.${var.domain} -> ${var.vps_ip}"
    terminal          = "terminal.${var.domain} -> ${var.vps_ip}"
    dashboard         = "dashboard.${var.domain} -> ${var.vps_ip}"
    staging_api       = "staging-api.${var.domain} -> ${var.vps_ip}"
    staging_terminal  = "staging-terminal.${var.domain} -> ${var.vps_ip}"
    staging_dashboard = "staging-dashboard.${var.domain} -> ${var.vps_ip}"
    argocd            = "argocd.${var.domain} -> ${var.vps_ip}"
    grafana           = "grafana.${var.domain} -> ${var.vps_ip}"
  }
}
