output "lambda_function_names" {
  value = { for k, v in aws_lambda_function.this : k => v.function_name }
}

output "lambda_arns" {
  value = { for k, v in aws_lambda_function.this : k => v.arn }
}

output "lambda_security_group_id" {
  value = aws_security_group.lambda.id
}
