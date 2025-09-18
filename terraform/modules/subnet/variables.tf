variable "vpc_id" {
  type = string
}

variable "name_sbn01" {
  type    = string
  default = "Subnet11"
}
variable "cidr_sbn01" {
  type    = string
  default = "10.1.1.0/24"
}
variable "type_sbn01" {
  type    = string
  default = "GENERAL"
}

variable "name_sbn02" {
  type    = string
  default = "SBNPRI01"
}
variable "cidr_sbn02" {
  type    = string
  default = "10.1.2.0/24"
}
variable "type_sbn02" {
  type    = string
  default = "GENERAL"
}