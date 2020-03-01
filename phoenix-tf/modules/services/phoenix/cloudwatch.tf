resource "aws_sns_topic" "cpu_peak_alert" {
  name = "${var.app_name}-cpu-peak-alert"

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.notification_email} --profile ${var.aws_profile} --region ${data.aws_region.current_region.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_used" {
  alarm_name          = "${var.app_name}-ecs-cpu-used-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"

  dimensions {
    ClusterName = var.cluster
    ServiceName = aws_ecs_service.service.name
  }

  alarm_description = "Send email notification at CPU peak"

  alarm_actions = [ aws_sns_topic.cpu_peak_alert.arn]
}