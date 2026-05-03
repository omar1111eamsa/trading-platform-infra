output "vps_ip" {
  description = "Public IP of the VPS"
  value       = ovh_cloud_project_instance.app_vps.ip_address
}

output "vps_name" {
  description = "Name of the VPS"
  value       = ovh_cloud_project_instance.app_vps.name
}

output "ssh_command" {
  description = "SSH command to connect to VPS"
  value       = "ssh ubuntu@${ovh_cloud_project_instance.app_vps.ip_address}"
}
