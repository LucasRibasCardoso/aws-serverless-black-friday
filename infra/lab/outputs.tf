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
