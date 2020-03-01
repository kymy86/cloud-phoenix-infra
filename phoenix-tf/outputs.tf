output "application_endpoint" {
    description = "Phoenix application URL"
    value = "http://${module.cluster.alb_url}"
}