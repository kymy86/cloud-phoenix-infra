variable "aws_region" {
  description = "AWS region where launch the infrastructure"
  type        = string
  default     = "eu-west-1"
}

variable "aws_az" {
  description = "Availability zones"
  type        = map(string)

  default = {
    eu-central-1 = "eu-central-1c,eu-central-1a,eu-central-1b"
    eu-west-1    = "eu-west-1c,eu-west-1a,eu-west-1b"
    eu-west-2    = "eu-west-2c,eu-west-2a,eu-west-2b"
  }
}

variable "aws_key_pair_name" {
  description = "Name of AWS key pair"
  type        = string
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

variable "aws_public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/public_key.pub
  DESCRIPTION

  type = string
}

variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
}

variable "app_name" {
  default = "phoenix"
  type    = string
}

variable "environment" {
  description = "Application environment"
  type        = string
  default     = "production"
}

variable "ips_bastion_source" {
  description = "CIDR addresses from where the SSH connection to the bastion host instance is allowed"
  type        = list(string)
}

variable "notification_email" {
  description = "Email address where send the notifications"
  type        = string
}

variable "cluster_max_size" {
  description = "Max number of instances for backend ECS cluster"
  type        = number
  default     = 3
}

variable "cluster_min_size" {
  description = "Min number of instances for backend ECS cluster"
  type        = number
  default     = 1
}

variable "docker_repo_url" {
  description = "URL of docker repository where phoenix source code is stored"
  type        = string
}
variable "container_port" {
  description = "Container port name"
  type        = string
  default     = "3000"
}

variable "image_name" {
  description = "Docker image name"
  type        = string
}

variable "backend_certificate" {
  description = "Certificate for HTTPS connection"
  type        = string
  default     = ""
}

variable "ssl" {
  description = "Decide if enable or not HTTPS"
  type        = number
  default     = 0
}

variable "github_repo" {
  type        = string
  description = "URL of GitHUB repository"
}

variable "github_oauth_token" {
  type        = string
  description = "GitHUB token"
}

variable "github_owner" {
  type        = string
  description = "GitHUB repo owner"
}

variable "github_repo_name" {
  type        = string
  description = "GitHUB repo name"
}
