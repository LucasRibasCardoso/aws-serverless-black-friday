output "account_id" {
  description = "ID da conta AWS onde o laboratório foi provisionado."
  value       = local.account_id
}

output "region" {
  description = "Região AWS onde o laboratório foi provisionado."
  value       = local.region
}

output "name_prefix" {
  description = "Prefixo usado no nome de todos os recursos."
  value       = local.name_prefix
}

# DynamoDB

output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB Single-Table do laboratório."
  value       = aws_dynamodb_table.this.name
}

output "dynamodb_table_arn" {
  description = "ARN da tabela DynamoDB Single-Table do laboratório."
  value       = aws_dynamodb_table.this.arn
}
