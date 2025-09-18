variable "common_tags" {
  type = map(string)
  default = {
    name      = "advance_iac"
    createdby = "terraform"
  }
}

variable "my_public_ip" {
  type        = string
  description = "Your public IP address for SSH and RDP access"
  default     = "x.x.x.x/32" # You need to replace this value to your public IP address.
}