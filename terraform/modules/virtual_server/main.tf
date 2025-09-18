

terraform {
  required_providers {
    samsungcloudplatformv2 = {
      version = "1.0.3"
      source  = "SamsungSDSCloud/samsungcloudplatformv2"
    }
  }
  required_version = ">= 1.11"
}

resource "samsungcloudplatformv2_vpc_publicip" "bastion_public_ip" {
  type        = "IGW"
  description = "Public IP for Bastion Server"
  tags = {
    name = "bastion_public_ip"
  }
}

data "samsungcloudplatformv2_virtualserver_keypair" "keypair" {
  name = var.name_keypair
}

resource "samsungcloudplatformv2_virtualserver_server" "server_001" {
  name           = var.name_vm
  state          = var.vmstate
  image_id       = var.image_id
  server_type_id = var.server_type_id
  keypair_name   = data.samsungcloudplatformv2_virtualserver_keypair.keypair.name

  networks = {
    nic0 = {
      subnet_id    = var.subnet_id
      fixed_ip     = var.fixed_ip
      public_ip_id = samsungcloudplatformv2_vpc_publicip.bastion_public_ip.id
    }
  }

  security_groups = [var.security_group_id]

  boot_volume = {
    size                  = var.boot_volume_size
    type                  = var.boot_volume_type
    delete_on_termination = true
  }

  tags = {
    name = var.name_vm
  }

  depends_on = [samsungcloudplatformv2_vpc_publicip.bastion_public_ip]
}