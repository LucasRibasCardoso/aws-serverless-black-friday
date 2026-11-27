variable "function_name" {
  description = "Nome completo da função Lambda (usado também como base para a IAM Role e o Log Group)."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]{1,64}$", var.function_name))
    error_message = "function_name deve ter de 1 a 64 caracteres contendo apenas letras, números, hífens ou underscores."
  }
}

variable "source_path" {
  description = "Caminho local do arquivo .zip contendo o pacote da função Lambda."
  type        = string

  validation {
    condition     = length(trimspace(var.source_path)) > 0
    error_message = "source_path não pode ser vazio."
  }
}

variable "source_code_hash" {
  description = "Hash Base64 SHA-256 do pacote .zip (ex.: output_base64sha256 de archive_file). Se nulo, é calculado automaticamente a partir de source_path."
  type        = string
  default     = null
}

variable "handler" {
  description = "Ponto de entrada (handler) da função Lambda (ex.: lambda-processor/processor.handler)."
  type        = string

  validation {
    condition     = length(trimspace(var.handler)) > 0
    error_message = "handler não pode ser vazio."
  }
}

variable "runtime" {
  description = "Runtime utilizado pela função Lambda."
  type        = string
  default     = "nodejs26.x"

  validation {
    condition     = length(trimspace(var.runtime)) > 0
    error_message = "runtime não pode ser vazio."
  }
}

variable "architectures" {
  description = "Arquitetura de CPU da função Lambda (arm64 ou x86_64)."
  type        = list(string)
  default     = ["x86_64"]

  validation {
    condition     = length(var.architectures) == 1 && contains(["arm64", "x86_64"], var.architectures[0])
    error_message = "architectures deve conter exatamente um valor válido: \"arm64\" ou \"x86_64\"."
  }
}

variable "memory_size" {
  description = "Quantidade de memória alocada para a função Lambda, em MB."
  type        = number
  default     = 512

  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240 && floor(var.memory_size) == var.memory_size
    error_message = "memory_size deve ser um número inteiro entre 128 e 10240 MB."
  }
}

variable "timeout" {
  description = "Tempo máximo de execução da função Lambda, em segundos."
  type        = number
  default     = 30

  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900 && floor(var.timeout) == var.timeout
    error_message = "timeout deve ser um número inteiro entre 1 e 900 segundos."
  }
}

variable "environment_variables" {
  description = "Variáveis de ambiente injetadas na função Lambda."
  type        = map(string)
  default     = {}
}

variable "policy_json" {
  description = "Documento JSON de política IAM inline com permissões adicionais (além dos logs no CloudWatch) para a role da função."
  type        = string
  default     = null
}

variable "log_retention_in_days" {
  description = "Tempo de retenção dos logs da função no CloudWatch Logs, em dias."
  type        = number
  default     = 7

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.log_retention_in_days)
    error_message = "log_retention_in_days deve ser um período de retenção suportado pelo CloudWatch Logs (ex.: 1, 3, 5, 7, 14, 30, 60, 90)."
  }
}

variable "tags" {
  description = "Tags extras aplicadas aos recursos criados pelo módulo (Name, Project e ManagedBy são gerenciadas automaticamente)."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k in keys(var.tags) : !contains(["Name", "Project", "ManagedBy"], k)])
    error_message = "As tags Name, Project e ManagedBy são reservadas e definidas automaticamente."
  }
}
