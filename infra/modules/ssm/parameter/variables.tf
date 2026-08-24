variable "name" {
  type        = string
  description = "パラメータ名（例: /dev-system/backend/django-secret）"
}

variable "description" {
  type        = string
  description = "パラメータの説明"
  default     = null
}

variable "type" {
  type        = string
  description = "パラメータの型（String / StringList / SecureString）"
  default     = "SecureString"
}

variable "value" {
  type        = string
  description = "パラメータの初期値。作成後の値の変更はTerraformの管理対象外（ignore_changes）"
  sensitive   = true
}

variable "tier" {
  type        = string
  description = "パラメータのティア（Standard / Advanced / Intelligent-Tiering）"
  default     = "Standard"
}
