

terraform {
  required_providers {
    samsungcloudplatformv2 = {
      version = "1.0.3"
      source  = "SamsungSDSCloud/samsungcloudplatformv2"
    }
  }
  required_version = ">= 1.11"
}

data "samsungcloudplatform_region" "region" {
}

// data "samsungcloudplatform_vpcs" "vpc01" {
// }

// data "samsungcloudplatform_subnets" "subnet01" {
// }

resource "samsungcloudplatformv2_virtualserver_keypair" "keypair" {
  name = var.name_keypair
}

resource "samsungcloudplatformv2_virtualserver_server" "server_001" {
  name           = var.name_vm
  state          = var.vmstate
  image_id       = "img-123456"  # Replace with actual image ID
  server_type_id = "stype-123456" # Replace with actual server type ID
  keypair_name   = samsungcloudplatformv2_virtualserver_keypair.keypair.name
  
  networks = {
    interface_1 : {
      subnet_id : var.subnet_id,
      ipv4_address : var.fixed_ip
    }
  }
  
  security_groups = [var.security_group_id]
  
  boot_volume = {
    size = 100
    type = "SSD"
    delete_on_termination = true
  }
  
  tags = {
    Name = var.name_vm
    Environment = "test"
  }
}