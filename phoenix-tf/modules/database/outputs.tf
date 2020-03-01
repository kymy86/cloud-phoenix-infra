
output "primary_ip" {
    description = "Primary IP address"
    value = aws_cloudformation_stack.mongo_primary_node.outputs.NodePrivateIp
}

output "primary_instance_id" {
    description = "Primary Instance ID"
    value = aws_cloudformation_stack.mongo_primary_node.outputs.NodeInstanceID
}

output "primary_name_tag" {
    description = "Primary Instance ID"
    value = aws_cloudformation_stack.mongo_primary_node.outputs.NodeNameTag
}

output "secondary_1_ip" {
    description = "Secondary IP address (1)"
    value = aws_cloudformation_stack.mongo_secondary_node_1.outputs.NodePrivateIp
}

output "secondary_1_id" {
    description = "Secondary Instance ID (1)"
    value = aws_cloudformation_stack.mongo_secondary_node_1.outputs.NodeInstanceID
}

output "secondary_1_tag" {
    description = "Secondary Instance ID (1)"
    value = aws_cloudformation_stack.mongo_secondary_node_1.outputs.NodeNameTag
}

output "secondary_2_ip" {
    description = "Secondary IP address (2)"
    value = aws_cloudformation_stack.mongo_secondary_node_2.outputs.NodePrivateIp
}

output "secondary_2_id" {
    description = "Secondary Instance ID (2)"
    value = aws_cloudformation_stack.mongo_secondary_node_2.outputs.NodeInstanceID
}

output "secondary_2_tag" {
    description = "Secondary Instance ID (2)"
    value = aws_cloudformation_stack.mongo_secondary_node_2.outputs.NodeNameTag
}

output "mongo_connection_string_app" {
    description = "Mongo Connection string"
    value = "mongodb://${var.mongodb_app_username}:${var.mongodb_app_user_password}@${aws_cloudformation_stack.mongo_primary_node.outputs.NodePrivateIp}:27017,${aws_cloudformation_stack.mongo_secondary_node_1.outputs.NodePrivateIp}:27017,${aws_cloudformation_stack.mongo_secondary_node_2.outputs.NodePrivateIp}:27017/${var.mongodb_db_app_name}?replicaSet=s0&authSource=admin"
}

output "mongo_connection_string_test_app" {
    description = "Mongo Connection string"
    value = "mongodb://${var.mongodb_app_test_username}:${var.mongodb_app_test_user_password}@${aws_cloudformation_stack.mongo_primary_node.outputs.NodePrivateIp}:27017,${aws_cloudformation_stack.mongo_secondary_node_1.outputs.NodePrivateIp}:27017,${aws_cloudformation_stack.mongo_secondary_node_2.outputs.NodePrivateIp}:27017/${var.mongodb_db_test_app_name}?replicaSet=s0&authSource=admin"
}