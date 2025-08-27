terraform {
  required_providers {
    samsungcloudplatform = {
      version = "3.12.0"
      source  = "SamsungSDSCloud/samsungcloudplatform"
    }
  }
  required_version = ">= 0.13"
}

data "samsungcloudplatform_vpcs" "vpc01" {
}

resource "samsungcloudplatform_security_group" "SGbastion" {
  vpc_id = var.vpc_id
  //  vpc_id  vpc_id      = data.samsungcloudplatform_vpcs.vpc01.contents[0].vpc_id
  name        = "SGbastion"
  is_loggable = false
}

resource "samsungcloudplatform_security_group_bulk_rule" "SGbastion_rule" {
  security_group_id = samsungcloudplatform_security_group.SGbastion.id
  rule {
    direction   = "in"
    description = "Allow inbound from Administrator PC"
    addresses_ipv4 = [
      var.my_ip
    ]
    service {
      type  = "tcp"
      value = "22"
    }
    service {
      type  = "tcp"
      value = "3389"
    }
  }
  rule {
    direction   = "out"
    description = "Allow HTTP/HTTPS outbound to Internet"
    addresses_ipv4 = [
      "0.0.0.0/0"
    ]
    service {
      type  = "tcp"
      value = "80"
    }
    service {
      type  = "tcp"
      value = "443"
    }
  }
}