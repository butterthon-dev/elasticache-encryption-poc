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

variable "github_repository" {
  type        = string
  description = "デプロイを許可するGitHubリポジトリ（org/repo形式）"
}

variable "github_allowed_refs" {
  type        = list(string)
  description = "デプロイを許可するgitのrefのリスト（例: refs/heads/main）"
  default     = ["refs/heads/main"]
}
