output "linux_vm_public_ip" {
  description = "Static public IP of the Linux VM (backend + frontends)."
  value       = aws_eip.linux_vm.public_ip
}

output "linux_vm_private_ip" {
  description = "Private IP of the Linux VM."
  value       = aws_instance.linux_vm.private_ip
}

output "linux_vm_id" {
  description = "EC2 instance ID of the Linux VM."
  value       = aws_instance.linux_vm.id
}

output "windows_vm_public_ip" {
  description = "Static public IP(s) of the Windows VM(s)."
  value       = aws_eip.windows_vm[*].public_ip
}

output "windows_vm_private_ip" {
  description = "Private IP(s) of the Windows VM(s)."
  value       = aws_instance.windows_vm[*].private_ip
}

output "windows_vm_id" {
  description = "EC2 instance ID(s) of the Windows VM(s)."
  value       = aws_instance.windows_vm[*].id
}

output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public subnet ID."
  value       = aws_subnet.public.id
}

output "dns_instructions" {
  description = "DNS records to create at your domain registrar."
  value       = <<-EOT
    Point these DNS A records to the Linux VM IP (${aws_eip.linux_vm.public_ip}):
      ${var.frontend_domain_name}  → ${aws_eip.linux_vm.public_ip}
      ${var.backend_domain_name}   → ${aws_eip.linux_vm.public_ip}
      ${var.terminal_domain_name}  → ${aws_eip.linux_vm.public_ip}
  EOT
}

output "ansible_inventory_file" {
  description = "Generated Ansible inventory (linux_ui + linux_api hosts on aws_instance.linux_vm, same public IP)."
  value       = abspath("${path.module}/../ansible/inventories/aws/hosts.generated.yml")
}

output "ansible_provision_hint" {
  description = "Example command to run Ansible manually after apply (test inventory supplies group_vars/host_vars; generated file supplies EIP and SSH key)."
  value       = "cd ../ansible && ansible-galaxy collection install -r collections/requirements.yml && ansible-playbook -i inventories/test/hosts.yml -i inventories/aws/hosts.generated.yml playbooks/site.yml"
}

output "ec2_private_key_path" {
  description = "Path to the RSA private key for ubuntu@linux and Administrator@windows (via EC2 Session Manager or after enabling SSH on Windows)."
  value       = abspath("${path.module}/generated/ec2_rsa.pem")
}
