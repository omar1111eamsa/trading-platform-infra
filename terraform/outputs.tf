output "frontend_external_ip" {
  description = "Ephemeral external IP of the frontend VM."
  value       = google_compute_instance.frontend_v1.network_interface[0].access_config[0].nat_ip
}

output "frontend_internal_ip" {
  description = "Internal IP of the frontend VM."
  value       = google_compute_instance.frontend_v1.network_interface[0].network_ip
}

output "backend_external_ip" {
  description = "Ephemeral external IP of the backend VM."
  value       = google_compute_instance.backend_v1.network_interface[0].access_config[0].nat_ip
}

output "backend_internal_ip" {
  description = "Internal IP of the backend VM."
  value       = google_compute_instance.backend_v1.network_interface[0].network_ip
}
