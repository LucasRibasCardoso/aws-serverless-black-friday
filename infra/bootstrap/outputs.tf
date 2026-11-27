output "state_bucket_name" {
  description = "Nome do bucket S3 que guarda o state remoto do projeto principal."
  value       = aws_s3_bucket.state.bucket
}

output "state_bucket_arn" {
  description = "ARN do bucket S3 de state."
  value       = aws_s3_bucket.state.arn
}

output "state_key" {
  description = "Path para o arquivo de state dentro do bucket S3."
  value       = local.state_key
}

output "region" {
  description = "Região AWS onde o bucket de state foi criado."
  value       = data.aws_region.current.region
}
