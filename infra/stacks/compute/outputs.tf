output "ecs_cluster_name" {
  description = "ECSクラスター名"
  value       = module.ecs_cluster.name
}

output "ecs_cluster_arn" {
  description = "ECSクラスターのARN"
  value       = module.ecs_cluster.arn
}

output "backend_service_name" {
  description = "バックエンドのECSサービス名"
  value       = module.backend_service.service_name
}

output "backend_service_arn" {
  description = "バックエンドのECSサービスのARN"
  value       = module.backend_service.arn
}

output "backend_task_definition_family" {
  description = "バックエンドのECSタスク定義のファミリー名"
  value       = module.backend_service.task_definition_family
}

output "backend_log_group_name" {
  description = "バックエンドのECSサービスのCloudWatchロググループ名"
  value       = module.backend_service.log_group_name
}

output "backend_task_role_arn" {
  description = "バックエンドのタスクロールのARN"
  value       = module.backend_task_role.arn
}

output "backend_task_execution_role_arn" {
  description = "バックエンドのタスク実行ロールのARN"
  value       = module.backend_task_execution_role.arn
}

output "backend_django_secret_parameter_name" {
  description = "Djangoシークレットキーを格納するSSMパラメータ名"
  value       = module.backend_django_secret.name
}
