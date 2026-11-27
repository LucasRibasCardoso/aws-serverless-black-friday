variable "aws_region" {
  description = "Região AWS onde o bucket de state será criado. Deve ser a mesma usada no backend.hcl do projeto principal."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}(-gov)?-[a-z]+-[0-9]$", var.aws_region))
    error_message = "aws_region deve ser um código de região válido (ex.: us-east-1, sa-east-1)."
  }
}

variable "project_name" {
  description = "Nome curto do projeto, usado como prefixo do bucket e na tag Project."
  type        = string
  default     = "black-friday-lab"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,23}[a-z0-9]$", var.project_name))
    error_message = "project_name deve ter de 3 a 25 caracteres: letras minúsculas, números e hífens, começando com letra."
  }
}

variable "noncurrent_version_retention_days" {
  description = "Dias que versões antigas do state ficam guardadas antes de expirar (permite rollback de um state corrompido)."
  type        = number
  default     = 90

  validation {
    condition     = var.noncurrent_version_retention_days >= 7 && var.noncurrent_version_retention_days <= 365
    error_message = "noncurrent_version_retention_days deve estar entre 7 e 365."
  }
}

variable "tags" {
  description = "Tags extras aplicadas a todos os recursos (as tags Project, Component e ManagedBy são adicionadas automaticamente)."
  type        = map(string)
  default     = {}
}
