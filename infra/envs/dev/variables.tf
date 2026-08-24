variable "env" {
  type        = string
  description = "環境名"
}

variable "system" {
  type        = string
  description = "システム名"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPCのCIDRブロック"
}

variable "public_subnets" {
  type        = map(string)
  description = "パブリックサブネットのマップ（key: AZ, value: CIDR）"
}

variable "private_subnets" {
  type        = map(string)
  description = "プライベートサブネットのマップ（key: AZ, value: CIDR）"
}

variable "github_subject_prefix" {
  type        = string
  description = "デプロイを許可するリポジトリを表すOIDCトークンのsubクレームの接頭辞"
}

variable "github_allowed_refs" {
  type        = list(string)
  description = "デプロイを許可するgitのrefのリスト（例: refs/heads/main）"
  default     = ["refs/heads/main"]
}
