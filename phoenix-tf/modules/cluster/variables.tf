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

variable "private_subnet_ids" {
  type = list

  description = <<DESCRIPTION
  List of private subnet ids where the autoscaling group
  instances will be located
DESCRIPTION
}

variable "public_subnet_ids" {
  type = list

  description = <<DESCRIPTION
  List of public subnet ids where the Application Load Balancer
  will be located
DESCRIPTION
}

variable "instance_type" {
  type = string
  description = "Cluster instance type"
  default = "m4.large"
}

variable "key_pair_name" {
  description = "Name of AWS key pair"
  type        = string
}

variable "bastion_sg" {
  type = string

  description = <<DESCRIPTION
Bastion host instance security group id
from where the SSH access to the autoscaling instances
is allowed.
DESCRIPTION
}

variable "ecs_config" {
  type        = string
  default     = "echo '' > /etc/ecs/ecs.config"
  description = "Specify ecs configuration or get it from S3. Example: aws s3 cp s3://some-bucket/ecs.config /etc/ecs/ecs.config"
}

variable "ecs_logging" {
  type        = string
  default     = "[\\\"json-file\\\",\\\"awslogs\\\"]"
  description = "Adding logging option to ECS that the Docker containers can use."
}

variable "max_size" {
  type        = string
  description = "Max instances for ECS cluster"
}

variable "min_size" {
  type        = string
  description = "Min instances for ECS cluster"
  default     = "1"
}

variable "healthcheck_path" {
  type        = string
  description = "Healthcheck path"
  default = "/"
}