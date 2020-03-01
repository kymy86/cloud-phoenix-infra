variable "app_name" {
  type        = string
  description = "Application name"
}

variable "environment" {
  type        = string
  description = "Application environment"
}

variable "vpc_id" {
  type        = string
  description = "Id of the custom VPC"
}

variable "primary_node_subnet_id" {
    type = string
    description = "Subnet ID where will be placed the MongoDB primary node"
}

variable "secondary_node_1_subnet_id" {
    type = string
    description = "Subnet ID where will be placed the first of two MongoDB secondary node"
}

variable "secondary_node_2_subnet_id" {
    type = string
    description = "Subnet ID where will be placed the second of two MongoDB secondary node"
}

variable "bastion_sg" {
    type = string
    description = "Bastion host security group ID"
}

variable "key_pair_name" {
  description = "Name of AWS key pair"
  type        = string
}

variable "mongodb_admin_password" {
    description = "MongoDB Admin password"
    type = string
}

variable "mongodb_admin_username" {
    description = "MongoDB Admin username"
    type = string
}

variable "mongodb_app_user_password" {
    description = "MongoDB App user password"
    type = string
    default = "phoenixpwd"
}

variable "mongodb_app_username" {
    description = "MongoDB App username"
    type = string
    default = "phoenix"
}
variable "mongodb_app_test_user_password" {
    description = "MongoDB App Test user password"
    type = string
    default = "phoenixpwdtest"
}

variable "mongodb_app_test_username" {
    description = "MongoDB App Test username"
    type = string
    default = "phoenixtest"
}

variable "mongodb_version" {
    description = "MongoDB Version"
    type = string
    default = "4.0"
}

variable "mongodb_instance_type" {
    description = "MongoDB instance type"
    type = string
    default = "m4.large"
}

