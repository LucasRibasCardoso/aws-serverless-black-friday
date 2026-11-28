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

# SQS

output "sqs_order_queue_url" {
  description = "URL da fila SQS FIFO principal de pedidos."
  value       = aws_sqs_queue.order.url
}

output "sqs_order_queue_arn" {
  description = "ARN da fila SQS FIFO principal de pedidos."
  value       = aws_sqs_queue.order.arn
}

output "sqs_order_dlq_url" {
  description = "URL da Dead-Letter Queue (DLQ) FIFO de pedidos."
  value       = aws_sqs_queue.order_dlq.url
}

output "sqs_order_dlq_arn" {
  description = "ARN da Dead-Letter Queue (DLQ) FIFO de pedidos."
  value       = aws_sqs_queue.order_dlq.arn
}

# Lambda

output "lambda_controller_function_name" {
  description = "Nome da função Lambda Controller."
  value       = module.lambda_controller.function_name
}

output "lambda_controller_arn" {
  description = "ARN da função Lambda Controller."
  value       = module.lambda_controller.arn
}

output "lambda_generator_function_name" {
  description = "Nome da função Lambda Generator."
  value       = module.lambda_generator.function_name
}

output "lambda_generator_arn" {
  description = "ARN da função Lambda Generator."
  value       = module.lambda_generator.arn
}

output "lambda_processor_function_name" {
  description = "Nome da função Lambda Processor."
  value       = module.lambda_processor.function_name
}

output "lambda_processor_arn" {
  description = "ARN da função Lambda Processor."
  value       = module.lambda_processor.arn
}
