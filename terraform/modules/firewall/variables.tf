variable "internet_gateway_id" {
  type        = string
  description = "Internet Gateway ID"
}

variable "vm_ip" {
  type        = string
  description = "VM IP address"
  default     = "10.1.1.110"
}

variable "my_ip" {
  type        = string
  description = "Your public IP address"
}