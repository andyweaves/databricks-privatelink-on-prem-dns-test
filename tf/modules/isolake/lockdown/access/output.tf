output "locked_private_access_setting_id" {
  description = "The private access setting ID from this module"
  value       = databricks_mws_private_access_settings.pas_lockdown.private_access_settings_id
}

output "inbound_resolver_ips" {
  value = data.aws_route53_resolver_endpoint.transit.ip_addresses
}

output "private_hosted_zone" {
  value = aws_route53_zone.privatelink.name
}

output "windows_vm_public_ip" {

  value = aws_instance.windows_vm_frontend.public_ip
}

output "windows_vm_instance_id" {

  value = aws_instance.windows_vm_frontend.id
}

output "linux_vm_public_ip" {

  value = aws_instance.linux_vm_frontend.public_ip
}

output "linux_vm_instance_id" {

  value = aws_instance.linux_vm_frontend.id
}