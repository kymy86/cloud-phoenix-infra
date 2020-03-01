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

variable "alb_target_group" {
    type = string
    description  = "Application Load Balancer target group ID"
}

variable "notification_email" {
    type = string
    description = "Notification for CPU peak is sent here"
}

