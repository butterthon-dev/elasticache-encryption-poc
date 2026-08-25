output "replication_group_id" {
  description = "ElasticacheのレプリケーショングループID"
  value       = aws_elasticache_replication_group.this.id
}

output "port" {
  description = "Elasticacheの接続受付ポート"
  value       = var.port
}

output "ssm_primary_endpoint_arn" {
  description = "Elasticacheのプライマリエンドポイントを保持するSSMパラメータストアのARN"
  value       = try(aws_ssm_parameter.primary_endpoint[0].arn, null)
}

output "ssm_reader_endpoint_arn" {
  description = "Elasticacheのリーダーエンドポイントを保持するSSMパラメータストアのARN"
  value       = try(aws_ssm_parameter.reader_endpoint[0].arn, null)
}

output "ssm_configuration_endpoint_arn" {
  description = "クラスターモードを有効化したElasticacheの接続エンドポイントを保持するSSMパラメータストアのARN"
  value       = try(aws_ssm_parameter.configuration_endpoint[0].arn, null)
}
