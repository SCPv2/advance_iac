terraform {
  required_providers {
    samsungcloudplatformv2 = {
      version = "1.0.3"
      source  = "SamsungSDSCloud/samsungcloudplatformv2"
    }
  }
  required_version = ">= 1.11"
}

data "samsungcloudplatform_vpcs" "vpc01" {
}

resource "samsungcloudplatform_internet_gateway" "IGW_vpc1" {
  igw_type = var.type
  vpc_id   = var.vpc_id
}

data "samsungcloudplatform_internet_gateways" "IGW_vpc1" {
  vpc_id = var.vpc_id
}

resource "samsungcloudplatform_firewall" "FW_IGW_vpc1" {
  vpc_id = var.vpc_id
  target_id       = samsungcloudplatform_internet_gateway.IGW_vpc01.id
  enabled         = "true"
  logging_enabled = "false"
}