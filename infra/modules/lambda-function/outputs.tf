output "function_name" {
  description = "Nome da função Lambda."
  value       = aws_lambda_function.this.function_name
}

output "arn" {
  description = "ARN da função Lambda."
  value       = aws_lambda_function.this.arn
}

output "invoke_arn" {
  description = "ARN de invocação da função Lambda (usado em integrações como API Gateway)."
  value       = aws_lambda_function.this.invoke_arn
}

output "role_arn" {
  description = "ARN da IAM Role de execução da função Lambda."
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Nome da IAM Role de execução da função Lambda."
  value       = aws_iam_role.this.name
}

output "log_group_name" {
  description = "Nome do CloudWatch Log Group da função Lambda."
  value       = aws_cloudwatch_log_group.this.name
}

output "log_group_arn" {
  description = "ARN do CloudWatch Log Group da função Lambda."
  value       = aws_cloudwatch_log_group.this.arn
}
