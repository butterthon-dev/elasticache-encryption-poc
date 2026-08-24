output "github_actions_deploy_role_arn" {
  description = "GitHub Actionsのsecrets.AWS_DEPLOY_ROLE_ARNに設定するロールARN"
  value       = module.cicd.github_actions_deploy_role_arn
}

output "backend_ecr_repository_name" {
  description = "バックエンドのECRリポジトリ名"
  value       = module.cicd.backend_ecr_repository_name
}

output "ecs_cluster_name" {
  description = "ECSクラスター名"
  value       = module.compute.ecs_cluster_name
}

output "backend_service_name" {
  description = "バックエンドのECSサービス名"
  value       = module.compute.backend_service_name
}

output "backend_task_definition_family" {
  description = "バックエンドのECSタスク定義のファミリー名"
  value       = module.compute.backend_task_definition_family
}

output "backend_django_secret_parameter_name" {
  description = "Djangoシークレットキーを格納するSSMパラメータ名"
  value       = module.compute.backend_django_secret_parameter_name
}
