variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "regionid" {
  type    = string
  default = "KR-WEST-1"
}

variable "name_vm" {
  type    = string
  default = "vm111r"
}

variable "name_keypair" {
  type    = string
  default = "vm111r-key"
}

variable "security_group_id" {
  type = string
}

variable "fixed_ip" {
  type        = string
  default     = "10.1.1.111"
  description = "Fixed IP address for VM"
}

variable "server-type" {
  type    = string
  default = "s1v1m2"
}
variable "vmstate" {
  type    = string
  default = "RUNNING"
}