terraform {
  required_providers {
    samsungcloudplatformv2 = {
      version = "1.0.3"
      source  = "SamsungSDSCloud/samsungcloudplatformv2"
    }
  }
  required_version = ">= 1.11"
}

resource "samsungcloudplatformv2_vpc_subnet" "subnet01" {
  vpc_id      = var.vpc_id
  name        = var.name_sbn01
  type        = var.type_sbn01
  cidr        = var.cidr_sbn01
  description = "Public subnet for VPC1"
}

resource "samsungcloudplatformv2_vpc_subnet" "subnet02" {
  vpc_id      = var.vpc_id
  name        = var.name_sbn02
  type        = var.type_sbn02
  cidr        = var.cidr_sbn02
  description = "Private subnet for VPC1"
}
