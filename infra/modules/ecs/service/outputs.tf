output "service_name" {
  description = "ECSサービス名"
  value       = aws_ecs_service.this.name
}

output "arn" {
  description = "ECSサービスのARN"
  value       = aws_ecs_service.this.arn
}

output "task_definition_family" {
  description = "ECSタスク定義のファミリー名"
  value       = aws_ecs_task_definition.this.family
}

output "log_group_name" {
  description = "ECSサービスのCloudWatchロググループ名"
  value       = aws_cloudwatch_log_group.this.name
}
