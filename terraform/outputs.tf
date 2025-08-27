output "VPC" {
  value = module.vpc.vpc_id
}
output "InternetGateway" {
  value = module.internet_gateway.IGW_id
}
output "InternetGatewayFirewall" {
  value = module.internet_gateway.FW_IGW_id
}
output "PublicSubnet" {
  value = module.subnet.subnet01_id
}
output "PrivateSubnet" {
  value = module.subnet.subnet01_id
}
output "VirtualServer" {
  value = module.virtual_server.virtual_server_id
}