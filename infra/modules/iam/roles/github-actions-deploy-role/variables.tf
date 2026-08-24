variable "name_prefix" {
  type        = string
  description = "ロール名の接頭辞"
}

variable "oidc_provider_arn" {
  type        = string
  description = "GitHub ActionsのOIDCプロバイダーのARN"
}

variable "allowed_subjects" {
  type        = list(string)
  description = "Assumeを許可するOIDCトークンのsubクレームのリスト（例: repo:org/repo:ref:refs/heads/main）"

  validation {
    condition     = length(var.allowed_subjects) > 0
    error_message = "allowed_subjectsを空にすると全てのリポジトリからAssume可能になるため、1件以上指定してください。"
  }
}

variable "ecr_repository_arns" {
  type        = list(string)
  description = "イメージのpushを許可するECRリポジトリのARNリスト"
}

variable "ecs_service_arns" {
  type        = list(string)
  description = "デプロイ（UpdateService）を許可するECSサービスのARNリスト"
}

variable "pass_role_arns" {
  type        = list(string)
  description = "タスク定義の登録時にPassRoleを許可するロール（タスクロール・タスク実行ロール）のARNリスト"
}

variable "max_session_duration" {
  type        = number
  description = "Assume後のセッションの最大有効期間（秒）"
  default     = 3600
}
