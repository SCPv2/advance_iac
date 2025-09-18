output "VPC" {
  value = module.vpc.vpc_id
}
output "InternetGateway" {
  value = module.internet_gateway.igw_id
}
output "InternetGatewayFirewall" {
  value = module.firewall.fw_igw_id
}
output "Subnet11" {
  value = module.subnet.subnet11_id
}
output "VirtualServer" {
  value = module.virtual_server.virtual_server_id
}