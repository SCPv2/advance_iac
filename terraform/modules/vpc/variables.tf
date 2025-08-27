variable "name" {
  type        = string
  default     = "VPC1"
  description = "VPC name"
}

variable "cidr" {
  type        = string
  default     = "10.1.0.0/16"
  description = "VPC CIDR block"
}

variable "description" {
  type        = string
  default     = "VPC1 created by Terraform"
  description = "VPC description"
}