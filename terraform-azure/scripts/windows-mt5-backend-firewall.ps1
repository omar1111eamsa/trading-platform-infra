# Run on the Windows / MT5 Azure VM (e.g. Azure Run Command > RunPowerShellScript).
# Allows MT5 host to reach the Linux backend on the stage VNet after Windows Firewall is enabled.
# Adjust $linuxBackend if Terraform private IP changes (default 10.42.1.5).

$linuxBackend = "10.42.1.5"
$vnet         = "10.42.0.0/16"

@(
  "Trading-Backend-MT5-Bridge-Outbound",
  "Trading-Backend-API-Outbound",
  "Trading-Backend-VNet-TCP-Outbound",
  "Trading-Backend-From-Linux-Inbound"
) | ForEach-Object {
  Remove-NetFirewallRule -DisplayName $_ -ErrorAction SilentlyContinue
}

New-NetFirewallRule -DisplayName "Trading-Backend-MT5-Bridge-Outbound" `
  -Direction Outbound -Action Allow -Protocol TCP `
  -RemoteAddress $linuxBackend -RemotePort 5556,5557 -Profile Any

New-NetFirewallRule -DisplayName "Trading-Backend-API-Outbound" `
  -Direction Outbound -Action Allow -Protocol TCP `
  -RemoteAddress $linuxBackend -RemotePort 8081 -Profile Any

New-NetFirewallRule -DisplayName "Trading-Backend-VNet-TCP-Outbound" `
  -Direction Outbound -Action Allow -Protocol TCP `
  -RemoteAddress $vnet -Profile Any

New-NetFirewallRule -DisplayName "Trading-Backend-From-Linux-Inbound" `
  -Direction Inbound -Action Allow -Protocol TCP `
  -RemoteAddress $linuxBackend -LocalPort 5556,5557 -Profile Any

Get-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue | Enable-NetFirewallRule
Set-NetFirewallRule -DisplayGroup "Remote Desktop" -Enabled True -ErrorAction SilentlyContinue

Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
