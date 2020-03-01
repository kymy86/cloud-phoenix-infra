//role assumed by Task definition in the ECS
resource "aws_iam_role" "task_definition_role" {
  name               = "${var.app_name}_task_definition_role"
  assume_role_policy = file("${path.module}/policies/task-definition-assume-role-policy.json")
}

resource "aws_iam_role_policy" "ecs_td_policy" {
  name   = "${var.app_name}_ecs_td_policy"
  role   = aws_iam_role.task_definition_role.id
  policy = file("${path.module}/policies/task-definition-policy.json")
}

//role assumed by the ECS service 
resource "aws_iam_role" "service_role" {
  name               = "${var.app_name}_ecs_service_role"
  assume_role_policy = file("${path.module}/policies/service-assume-role-policy.json")
}

resource "aws_iam_role_policy" "ecs_service_policy" {
  name   = "${var.app_name}_service_policy"
  role   = aws_iam_role.service_role.id
  policy = file("${path.module}/policies/service-role-policy.json")
}


//roled assumed by the Autoscaling group to scale the ECS cluster
resource "aws_iam_role" "ecs_autoscaling_role" {
  name               = "ecs_autoscaling_role"
  assume_role_policy = file("${path.module}/policies/assume-role-autoscaling.json")
}

resource "aws_iam_role_policy" "ecs_autoscaling_policy" {
  name   = "ecs_autoscaling_policy"
  role   = aws_iam_role.ecs_autoscaling_role.id
  policy = file("${path.module}/policies/autoscaling-role.json")
}