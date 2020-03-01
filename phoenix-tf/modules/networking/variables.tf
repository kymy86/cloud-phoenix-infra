variable "app_name" {
  type = string
}

variable "environment" {
  description = "Environment name"
  default = "Production"
  type        = string
}

variable "vpc_cidr_block" {
  type        = string
  description = "Custom VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "az_zones" {
  type = string
}