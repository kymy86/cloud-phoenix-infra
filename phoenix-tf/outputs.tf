output "application_endpoint" {
    description = "Phoenix application URL"
    value = "http://${module.cluster.alb_url}"
}

output "mongo_connection_string_app" {
    description = "Mongo Connection string"
    value = module.database.mongo_connection_string_app
}

output "mongo_connection_string_test_app" {
    description = "Mongo Connection string"
    value = module.database.mongo_connection_string_test_app
}
