#Saving the database connection strings in the parameter store.


resource "aws_ssm_parameter" "connection_string_prod" {
    name = "/${var.app_name}/db_connection_string"
    description = "MongoDB connection string to prod"
    type = "SecureString"
    value = var.mongo_prod_connection_string

    tags = {
        Environment = var.environment
        Application = var.app_name
    }
}

resource "aws_ssm_parameter" "connection_string_test" {
    name = "/${var.app_name}/db_test_connection_string"
    description = "MongoDB connection string to test database"
    type = "SecureString"
    value = var.mongo_test_connection_string

    tags = {
        Environment = var.environment
        Application = var.app_name
    }
}