

output "cluster_id" {
  value = aws_ecs_cluster.ecs_cluster.id
}

output "sg_id" {
  value = aws_security_group.cluster_security_group.id
}

output "alb_url" {
  description = "Load Balancer DNS"
  value       = aws_alb.loadbalancer.dns_name
}

output "alb_target_group_id" {
  value = aws_alb_target_group.target_group.id
}

output "cluster_security_group" {
  value = aws_security_group.cluster_security_group.id
}

/*
* these two parameters is needed to use the RequestCountPerTarget as metric
* for the TrackScalingPolicy of the ECS Service
*/

output "resource_label_lb" {
  value = replace(aws_alb.loadbalancer.arn, "arn:aws:elasticloadbalancing:${data.aws_region.current_region.name}:${data.aws_caller_identity.current.account_id}:loadbalancer/", "")
}

output "resource_label_targetgroup" {
  value = replace(aws_alb_target_group.target_group.arn, "arn:aws:elasticloadbalancing:${data.aws_region.current_region.name}:${data.aws_caller_identity.current.account_id}:", "")
}
