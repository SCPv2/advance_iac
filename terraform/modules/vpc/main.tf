terraform {
  required_providers {
    samsungcloudplatformv2 = {
      version = "2.0.3"
      source  = "SamsungSDSCloud/samsungcloudplatformv2"
    }
  }
  required_version = ">= 1.11"
}

resource "samsungcloudplatformv2_vpc_vpc" "vpc1" {
  name        = var.name
  cidr        = var.cidr
  description = var.description
  tags = {
    name = var.name
  }
}