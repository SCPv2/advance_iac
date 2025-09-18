variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "name_vm" {
  type    = string
  default = "bastionvm110r"
}

variable "name_keypair" {
  type    = string
  default = "mykey_e"
}

variable "security_group_id" {
  type = string
}

variable "fixed_ip" {
  type        = string
  default     = "10.1.1.110"
  description = "Fixed IP address for VM"
}

variable "vmstate" {
  type    = string
  default = "ACTIVE"
}

variable "server_type_id" {
  type    = string
  default = "s2v1m2"
}

variable "image_id" {
  type    = string
#  default = "253a91ea-1221-49d7-af53-a45c389e7e1a"
  default = "99b329ad-14e1-4741-b3ef-2a330ef81074"  
}

variable "boot_volume_size" {
  type    = number
  default = 16
}

variable "boot_volume_type" {
  type    = string
  default = "SSD"
}