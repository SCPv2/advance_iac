terraform {
  required_providers {
    samsungcloudplatformv2 = {
      version = "2.0.3"
      source  = "SamsungSDSCloud/samsungcloudplatformv2"
    }
  }
  required_version = ">= 1.11"
}

data "samsungcloudplatformv2_firewall_firewalls" "fw_igw" {
  product_type = ["IGW"]
  size         = 1

  depends_on = [var.internet_gateway_id]
}

locals {
  igw_firewall_id = try(data.samsungcloudplatformv2_firewall_firewalls.fw_igw.ids, "")
}

resource "samsungcloudplatformv2_firewall_firewall_rule" "ssh_in_fw" {
  firewall_id = local.igw_firewall_id[0]
  firewall_rule_create = {
    action              = "ALLOW"
    direction           = "INBOUND"
    status              = "ENABLE"
    source_address      = [var.my_ip]
    destination_address = [var.vm_ip]
    description         = "SSH inbound"
    service = [
      { service_type = "TCP", service_value = "22" }
    ]
  }
  depends_on = [var.internet_gateway_id]
}

resource "samsungcloudplatformv2_firewall_firewall_rule" "rdp_in_fw" {
  firewall_id = local.igw_firewall_id[0]
  firewall_rule_create = {
    action              = "ALLOW"
    direction           = "INBOUND"
    status              = "ENABLE"
    source_address      = [var.my_ip]
    destination_address = [var.vm_ip]
    description         = "RDP inbound"
    service = [
      { service_type = "TCP", service_value = "3389" }
    ]
  }
  depends_on = [samsungcloudplatformv2_firewall_firewall_rule.ssh_in_fw]
}

resource "samsungcloudplatformv2_firewall_firewall_rule" "http_out_fw" {
  firewall_id = local.igw_firewall_id[0]
  firewall_rule_create = {
    action              = "ALLOW"
    direction           = "OUTBOUND"
    status              = "ENABLE"
    source_address      = [var.vm_ip]
    destination_address = ["0.0.0.0/0"]
    description         = "HTTP outbound"
    service = [
      { service_type = "TCP", service_value = "80" }
    ]
  }
  depends_on = [samsungcloudplatformv2_firewall_firewall_rule.rdp_in_fw]
}

resource "samsungcloudplatformv2_firewall_firewall_rule" "https_out_fw" {
  firewall_id = local.igw_firewall_id[0]
  firewall_rule_create = {
    action              = "ALLOW"
    direction           = "OUTBOUND"
    status              = "ENABLE"
    source_address      = [var.vm_ip]
    destination_address = ["0.0.0.0/0"]
    description         = "HTTPS outbound"
    service = [
      { service_type = "TCP", service_value = "443" }
    ]
  }
  depends_on = [samsungcloudplatformv2_firewall_firewall_rule.http_out_fw]
}