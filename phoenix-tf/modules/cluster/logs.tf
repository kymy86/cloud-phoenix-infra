resource "aws_cloudwatch_log_group" "messages_log_group" {
  name              = "/${var.app_name}/var/log/messages"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "docker_log_group" {
  name              = "/${var.app_name}/var/log/docker"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "ecs_init_log_group" {
  name              = "/${var.app_name}/var/log/ecs/ecs-init"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "ecs_agent_log_group" {
  name              = "/${var.app_name}/var/log/ecs/ecs-agent"
  retention_in_days = 7
}
