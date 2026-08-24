variable "name_prefix" {
  type        = string
  description = "CI/CD関連リソース名の接頭辞"
}

variable "github_subject_prefix" {
  type        = string
  description = <<-EOT
    デプロイを許可するリポジトリを表すOIDCトークンのsubクレームの接頭辞。
    通常は "repo:<org>/<repo>" だが、immutable subject claimが有効なOrganizationでは
    "repo:<org>@<org_id>/<repo>@<repo_id>" になる。以下のコマンドで実際の値を取得できる。
      gh api /repos/<org>/<repo>/actions/oidc/customization/sub --jq .sub_claim_prefix
  EOT

  validation {
    condition     = startswith(var.github_subject_prefix, "repo:")
    error_message = "github_subject_prefixは\"repo:\"で始まる必要があります。"
  }
}

variable "github_allowed_refs" {
  type        = list(string)
  description = "デプロイを許可するgitのrefのリスト（例: refs/heads/main）"
  default     = ["refs/heads/main"]
}

variable "ecs_service_arns" {
  type        = list(string)
  description = "デプロイ対象のECSサービスのARNリスト"
}

variable "pass_role_arns" {
  type        = list(string)
  description = "タスク定義の登録時にPassRoleを許可するロール（タスクロール・タスク実行ロール）のARNリスト"
}
