terraform {
  required_providers {
    samsungcloudplatformv2 = {
      version = "2.0.3"
      source  = "SamsungSDSCloud/samsungcloudplatformv2"
    }
  }
  required_version = ">= 1.11"
}

resource "samsungcloudplatformv2_vpc_subnet" "subnet11" {
  vpc_id      = var.vpc_id
  name        = var.name
  type        = var.type
  cidr        = var.cidr
  description = "${var.name} created by Terraform"
  tags = {
    name = var.name
  }
}
