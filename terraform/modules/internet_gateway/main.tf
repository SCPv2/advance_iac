terraform {
  required_providers {
    samsungcloudplatformv2 = {
      version = "2.0.3"
      source  = "SamsungSDSCloud/samsungcloudplatformv2"
    }
  }
  required_version = ">= 1.11"
}


resource "samsungcloudplatformv2_vpc_internet_gateway" "IGW_vpc1" {
  type              = var.type
  vpc_id            = var.vpc_id
  firewall_enabled  = true
  firewall_loggable = false
  tags = {
    name = "IGW_vpc1"
  }
}


