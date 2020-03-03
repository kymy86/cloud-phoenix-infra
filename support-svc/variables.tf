variable "aws_region" {
  description = "AWS region where launch the infrastructure"
  type        = string
  default     = "eu-west-1"
}

variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
}

variable "app_name" {
  type    = string
  default = "phoenix"
}

variable "state_bucket_name" {
  type        = string
  description = "Terraform state bucket name"
  default     = "-terraform-bucket"
}

variable "lock_table_name" {
  type        = string
  description = "Name of the Dynamo DB table where store the lock"
  default     = "-terraform-state-locking"
}
