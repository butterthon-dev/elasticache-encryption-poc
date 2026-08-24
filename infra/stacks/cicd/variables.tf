variable "name_prefix" {
  type        = string
  description = "CI/CD関連リソース名の接頭辞"
}

variable "github_repository" {
  type        = string
  description = "デプロイを許可するGitHubリポジトリ（org/repo形式）"
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
