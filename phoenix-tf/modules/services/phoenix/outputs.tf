output "test_db_param_name" {
    value = aws_ssm_parameter.connection_string_test.name
}