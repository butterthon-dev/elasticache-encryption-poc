output "id" {
  description = "ECSクラスターのID"
  value       = aws_ecs_cluster.this.id
}

output "name" {
  description = "ECSクラスター名"
  value       = aws_ecs_cluster.this.name
}

output "arn" {
  description = "ECSクラスターのARN"
  value       = aws_ecs_cluster.this.arn
}
