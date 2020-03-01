variable "vpc_id" {
  type = string
}

variable "app_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "bastion_instance_type" {
  default     = "t3.micro"
  type        = string
  description = "Bastion host instance type"
}

variable "aws_key_pair_name" {
  description = "Name of AWS key pair"
  type        = string
}

variable "subnet_ids" {
  description = "list of subnet ids for the Bastion Host"
  type        = list(string)
}

variable "ssh_user" {
  description = "username for accessing via SSH"
  type        = string
  default     = "ec2-user"
}

variable "aws_private_key_path" {
  description = <<DESCRIPTION
Path to the SSH private key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/private_key.pem
  DESCRIPTION

  type = string
}

variable "ips_bastion_source" {
  description = "Bastion host access is allowed only from this ip addresses"
  type = list(string)
}