variable "app_name" {
  type        = string
  description = "Application name"
}

variable "svc_name" {
  type = string
  description = "Service name"
  default = "phoenix"
}

variable "environment" {
  type        = string
  description = "Application environment"
}

variable "cluster_id" {
    type = string
    description = "ECS cluster ID"
}

variable "aws_profile" {
  type = string
  description = "Name of AWS CLI profile"
}

variable "min_size" {
  type = number
  description = "Min number of the app instances for the service"
  default = 1
}

variable "max_size" {
    type = number
    description = "Max number of the app instances for the service"
    default = 3
}

variable "docker_repo_url" {
  type = string
  description = "Repository of ECR docker image"
}

variable "container_port" {
    type = string
    description = "Application port"
    default = "3000"
}

variable "container_name" {
    type = string
    description = "Docker image name"
    default = "3000"
}

variable "alb_target_group" {
    type = string
    description  = "Application Load Balancer target group ID"
}

variable "notification_email" {
    type = string
    description = "Notification for CPU peak is sent here"
}

variable "mongo_prod_connection_string" {
  type = string
  description = "Production database connection string"
}


variable "mongo_test_connection_string" {
  type = string
  description = "Test database connection string"
}

variable "depends_id" {
  type = string
  description = "Workaround to wait for the NAT gateway to finish before starting the instances"
}

variable "resource_label" {
  type = string
  description = "resource label for ALBRequestCountPerTarget metric"
}