variable "aws_region" {
  description = "Região AWS onde todo o laboratório é provisionado."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}(-gov)?-[a-z]+-[0-9]$", var.aws_region))
    error_message = "aws_region deve ser um código de região válido (ex.: us-east-1, sa-east-1)."
  }
}

variable "project_name" {
  description = "Nome curto do projeto, usado como prefixo no nome de todos os recursos e na tag Project."
  type        = string
  default     = "black-friday-lab"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,23}[a-z0-9]$", var.project_name))
    error_message = "project_name deve ter de 3 a 25 caracteres: letras minúsculas, números e hífens, começando com letra."
  }
}

variable "tags" {
  description = "Tags extras aplicadas a todos os recursos (Project e ManagedBy são adicionadas automaticamente)."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k in keys(var.tags) : !contains(["Project", "ManagedBy"], k)])
    error_message = "As tags Project e ManagedBy são reservadas e definidas automaticamente."
  }
}

# DynamoDB

variable "dynamodb_max_read_request_units" {
  description = "Limite máximo de RRUs/s (Read Request Units) configurado na tabela DynamoDB em modo On-Demand."
  type        = number
  default     = 12000

  validation {
    condition     = var.dynamodb_max_read_request_units >= 1 && floor(var.dynamodb_max_read_request_units) == var.dynamodb_max_read_request_units
    error_message = "dynamodb_max_read_request_units deve ser um número inteiro maior ou igual a 1."
  }
}

variable "dynamodb_max_write_request_units" {
  description = "Limite máximo de WRUs/s (Write Request Units) configurado na tabela DynamoDB em modo On-Demand."
  type        = number
  default     = 4000

  validation {
    condition     = var.dynamodb_max_write_request_units >= 1 && floor(var.dynamodb_max_write_request_units) == var.dynamodb_max_write_request_units
    error_message = "dynamodb_max_write_request_units deve ser um número inteiro maior ou igual a 1."
  }
}

# SQS

variable "sqs_message_visibility_timeout_seconds" {
  description = "Tempo máximo durante o qual o processamento de uma mensagem deve ser concluído antes que a mensagem se torne disponível para outros consumidores."
  type        = number
  default     = 180 # 3 minutos

  validation {
    condition     = var.sqs_message_visibility_timeout_seconds >= 0 && var.sqs_message_visibility_timeout_seconds <= 43200 && floor(var.sqs_message_visibility_timeout_seconds) == var.sqs_message_visibility_timeout_seconds
    error_message = "sqs_message_visibility_timeout_seconds deve ser um número inteiro entre 0 e 43200."
  }
}

variable "sqs_max_receive_count" {
  description = "Número máximo de recebimentos de uma mensagem antes de ser redirecionada para a DLQ."
  type        = number
  default     = 3

  validation {
    condition     = var.sqs_max_receive_count >= 1 && var.sqs_max_receive_count <= 1000 && floor(var.sqs_max_receive_count) == var.sqs_max_receive_count
    error_message = "sqs_max_receive_count deve ser um número inteiro entre 1 e 1000."
  }
}
