data "aws_region" "current_region" {}

resource "aws_cloudwatch_log_group" "cw_log_group" {
  name              = "/${var.app_name}/${var.svc_name}"
  retention_in_days = 7
}

data "template_file" "td_template" {
  template = file("${path.module}/templates/task_definition.json")

  vars = {
    docker_repo          = var.docker_repo_url
    container_port       = var.container_port
    container_name       = var.app_name
    app_name             = "${var.app_name}-${var.svc_name}"
    cwlogs_group_main    = aws_cloudwatch_log_group.cw_log_group.name
    region_name          = data.aws_region.current_region.name
    cw_prefix            = var.app_name
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "${var.app_name}-${var.svc_name}"
  container_definitions = data.template_file.td_template.rendered
  task_role_arn         = aws_iam_role.task_definition_role.arn
}

resource "aws_ecs_service" "service" {
    name            = "${var.svc_name}-svc"
    cluster         = var.cluster_id
    task_definition = aws_ecs_task_definition.task_definition.arn
    desired_count   = var.min_size
    iam_role        = aws_iam_role.service_role.arn

    ordered_placement_strategy {
        type  = "binpack"
        field = "memory"
    }

    ordered_placement_strategy {
        type  = "spread"
        field = "instanceId"
    }

    load_balancer {
        target_group_arn = var.alb_target_group
        container_name   = var.container_name
        container_port   = var.container_port
    }

    lifecycle {
        ignore_changes = [desired_count, task_definition]
    }

}

/*
* SCALE OUT the services on the cluster based on the requests per second
*/

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.max_size
  min_capacity       = var.min_size
  resource_id        = "service/${var.app_name}/${aws_ecs_service.service.name}"
  role_arn           = aws_iam_role.ecs_autoscaling_role.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_app_up_policy" {
  name               = "${var.app_name}-rps-auto-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
      predefined_metric_specification {
          predefined_metric_type = "ALBRequestCountPerTarget"
          resource_label = var.resource_label
      }

      target_value = 600 #the minimum metric granularity is 1 minute, so 10 rps == 600 rpm
      scale_in_cooldown  = 180
      scale_out_cooldown = 180
  }

  depends_on = [aws_appautoscaling_target.ecs_target]
}
