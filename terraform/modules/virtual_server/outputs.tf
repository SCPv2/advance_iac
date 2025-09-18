output "virtual_server_id" {
  value = samsungcloudplatformv2_virtualserver_server.server_001.id
}

output "vm_ip" {
  value = samsungcloudplatformv2_virtualserver_server.server_001.networks.nic0.fixed_ip
}

output "public_ip_id" {
  value = samsungcloudplatformv2_vpc_publicip.bastion_public_ip.id
}

output "public_ip_address" {
  value = samsungcloudplatformv2_vpc_publicip.bastion_public_ip.publicip.ip_address
}