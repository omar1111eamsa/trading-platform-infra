output "resource_group_name" {
  description = "Azure resource group containing the Windows VM."
  value       = azurerm_resource_group.main.name
}

output "windows_public_ip" {
  description = "Public IP for RDP to the Windows / MT5 VM."
  value       = azurerm_public_ip.windows.ip_address
}

output "windows_private_ip" {
  description = "Private IP of the Windows VM."
  value       = azurerm_network_interface.windows.private_ip_address
}

output "rdp_command" {
  description = "RDP command example for Windows VM (macOS/Ubuntu)."
  value       = "xfreerdp /u:${var.windows_admin_username} /v:${azurerm_public_ip.windows.ip_address}"
}
