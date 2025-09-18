variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "name" {
  type        = string
  default     = "Subnet11"
  description = "Subnet name"
}

variable "cidr" {
  type        = string
  default     = "10.1.1.0/24"
  description = "Subnet CIDR block"
}

variable "type" {
  type        = string
  default     = "GENERAL"
  description = "Subnet for bastion"
}