output "github_actions_deploy_role_arn" {
  description = "GitHub Actionsのaws-actions/configure-aws-credentialsに渡すロールARN"
  value       = module.github_actions_deploy_role.arn
}

output "backend_ecr_repository_name" {
  description = "バックエンドのECRリポジトリ名"
  value       = module.backend_ecr.name
}

output "backend_ecr_repository_url" {
  description = "バックエンドのECRリポジトリのURL"
  value       = module.backend_ecr.repository_url
}
