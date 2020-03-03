variable "app_name" {
  default = "phoenix"
  type    = string
}

variable "docker_registry_url" {
  type        = string
  description = "Docker Registry URL"
}

variable "github_repo" {
  type        = string
  description = "URL of GitHUB repository"
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type        = list
  description = "list of privat subnets id"
}

variable "security_group_ids" {
  type        = list
  description = "list of security groups is"
}

variable "ssm_test_db_parameter" {
  type        = string
  description = "Parameter name with the the test db connection"
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

variable "github_branch" {
  type        = string
  default     = "master"
  description = "GitHUB repo branch"
}
