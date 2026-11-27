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
