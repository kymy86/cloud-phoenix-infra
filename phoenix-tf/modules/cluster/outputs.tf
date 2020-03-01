

output "cluster_id" {
    value = aws_ecs_cluster.dr_cluster.id
}

output "sg_id" {
    value = aws_security_group.cluster_security_group.id
}

output "alb_url" {
  description = "Load Balancer DNS"
  value       = aws_alb.loadbalancer.dns_name
}

output  "alb_target_group_id" {
    value = aws_alb_target_group.target_group.id
}