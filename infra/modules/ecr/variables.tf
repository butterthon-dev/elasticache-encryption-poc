variable "name_prefix" {
  type        = string
  description = "ECRリポジトリ名の接頭辞"
}

variable "name" {
  type        = string
  description = "ECRリポジトリ名"
}

variable "image_tag_mutability" {
  type        = string
  description = "イメージタグの上書きを許可するかどうか（MUTABLE / IMMUTABLE）"
  default     = "MUTABLE"
}

variable "force_delete" {
  type        = bool
  description = "イメージが残っている状態でもリポジトリを削除できるようにするかどうか"
  default     = true
}

variable "scan_on_push" {
  type        = bool
  description = "push時に脆弱性スキャンを実行するかどうか"
  default     = true
}

variable "untagged_image_count_limit" {
  type        = number
  description = "保持するタグなしイメージの上限数。これを超えた古いイメージはライフサイクルポリシーで削除される"
  default     = 3
}
