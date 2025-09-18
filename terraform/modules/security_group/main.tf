terraform {
  required_providers {
    samsungcloudplatformv2 = {
      version = "1.0.3"
      source  = "SamsungSDSCloud/samsungcloudplatformv2"
    }
  }
  required_version = ">= 1.11"
}


resource "samsungcloudplatformv2_security_group_security_group" "bastionSG" {
  name     = var.bastion_sg_name
  loggable = false
  tags = {
    name = var.bastion_sg_name
  }
}

resource "samsungcloudplatformv2_security_group_security_group_rule" "bastion_ssh_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = samsungcloudplatformv2_security_group_security_group.bastionSG.id
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  description       = "SSH inbound from Administrator PC"
  remote_ip_prefix  = var.my_ip
}

resource "samsungcloudplatformv2_security_group_security_group_rule" "bastion_rdp_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = samsungcloudplatformv2_security_group_security_group.bastionSG.id
  protocol          = "tcp"
  port_range_min    = 3389
  port_range_max    = 3389
  description       = "RDP inbound from Administrator PC"
  remote_ip_prefix  = var.my_ip

  depends_on = [
    samsungcloudplatformv2_security_group_security_group_rule.bastion_ssh_in
  ]
}

resource "samsungcloudplatformv2_security_group_security_group_rule" "bastion_http_out" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = samsungcloudplatformv2_security_group_security_group.bastionSG.id
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  description       = "HTTP outbound to Internet"
  remote_ip_prefix  = "0.0.0.0/0"

  depends_on = [
    samsungcloudplatformv2_security_group_security_group_rule.bastion_rdp_in
  ]
}

resource "samsungcloudplatformv2_security_group_security_group_rule" "bastion_https_out" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = samsungcloudplatformv2_security_group_security_group.bastionSG.id
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  description       = "HTTPS outbound to Internet"
  remote_ip_prefix  = "0.0.0.0/0"

  depends_on = [
    samsungcloudplatformv2_security_group_security_group_rule.bastion_http_out
  ]
}