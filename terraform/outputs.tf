output "frontend_external_ip" {
  description = "Static external IP of the frontend VM."
  value       = google_compute_address.frontend_public_ip.address
}

output "frontend_internal_ip" {
  description = "Internal IP of the frontend VM."
  value       = google_compute_instance.frontend_v1.network_interface[0].network_ip
}

output "backend_external_ip" {
  description = "Static external IP of the backend VM."
  value       = google_compute_address.backend_public_ip.address
}

output "backend_internal_ip" {
  description = "Internal IP of the backend VM."
  value       = google_compute_instance.backend_v1.network_interface[0].network_ip
}

output "windows_external_ip" {
  description = "Static external IP(s) of the Windows VM(s)."
  value       = google_compute_address.windows_public_ip[*].address
}

output "windows_internal_ip" {
  description = "Internal IP(s) of the Windows VM(s)."
  value       = google_compute_instance.windows_v1[*].network_interface[0].network_ip
}

output "mt5_worker_external_ip" {
  description = "Static external IP(s) for future MT5 worker VMs."
  value       = google_compute_address.mt5_worker_public_ip[*].address
}

output "mt5_worker_internal_ip" {
  description = "Internal IP(s) for future MT5 worker VMs."
  value       = google_compute_instance.mt5_worker[*].network_interface[0].network_ip
}

output "frontend_domain_name" {
  description = "Configured frontend domain name."
  value       = var.frontend_domain_name
}

output "backend_domain_name" {
  description = "Configured backend domain name."
  value       = var.backend_domain_name
}
