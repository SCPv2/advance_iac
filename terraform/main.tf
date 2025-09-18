terraform {
  required_providers {
    samsungcloudplatformv2 = {
      version = "1.0.3"
      source  = "SamsungSDSCloud/samsungcloudplatformv2"
    }
  }
  required_version = ">= 1.11"
}

provider "samsungcloudplatformv2" {
}

module "vpc" {
  source = "./modules/vpc"
}

module "internet_gateway" {
  source = "./modules/internet_gateway"
  vpc_id = module.vpc.vpc_id
}

module "subnet" {
  source     = "./modules/subnet"
  vpc_id     = module.vpc.vpc_id
  depends_on = [module.internet_gateway]
}

module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
  my_ip  = var.my_public_ip
}

module "firewall" {
  source               = "./modules/firewall"
  internet_gateway_id  = module.internet_gateway.igw_id
  my_ip               = var.my_public_ip
  depends_on          = [module.internet_gateway]
}

module "virtual_server" {
  source            = "./modules/virtual_server"
  vpc_id            = module.vpc.vpc_id
  security_group_id = module.security_group.security_group_id
  subnet_id         = module.subnet.subnet11_id
  depends_on        = [module.subnet, module.firewall]
}