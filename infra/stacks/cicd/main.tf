# GitHub ActionsのOIDCプロバイダー
#
# アカウント全体で共有されるリソースなので、このスタックでは管理せず参照のみ行う。
data "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

locals {
  # OIDCトークンのsubクレーム。指定したリポジトリの指定したrefからのAssumeのみを許可する
  allowed_subjects = [
    for ref in var.github_allowed_refs : "${var.github_subject_prefix}:ref:${ref}"
  ]
}

# バックエンドのコンテナイメージ置き場
module "backend_ecr" {
  source = "../../modules/ecr"

  name_prefix = var.name_prefix
  name        = "backend"
}

# GitHub Actionsがビルド・デプロイに使うロール
module "github_actions_deploy_role" {
  source = "../../modules/iam/roles/github-actions-deploy-role"

  name_prefix         = var.name_prefix
  oidc_provider_arn   = data.aws_iam_openid_connect_provider.github_actions.arn
  allowed_subjects    = local.allowed_subjects
  ecr_repository_arns = [module.backend_ecr.arn]
  ecs_service_arns    = var.ecs_service_arns
  pass_role_arns      = var.pass_role_arns
}
