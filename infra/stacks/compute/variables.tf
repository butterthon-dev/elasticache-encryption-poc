variable "env" {
  type        = string
  description = "環境名"
}

variable "name_prefix" {
  type        = string
  description = "ネットワーク関連リソース名の接頭辞"
}

variable "hosted_zone_name" {
  type        = string
  description = "ホストゾーン名"
}

variable "vpc_id" {
  type        = string
  description = "VPCのID"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPCのCIDR"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "パブリックサブネットIDのリスト"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "プライベートサブネットIDのリスト"
}

variable "gateway_vpce_prefix_list_maps" {
  type        = map(string)
  description = "Gateway VPC Endpointのプレフィックスリストのマップ（複数の CIDR ブロック（IPアドレス範囲）をまとめたもの）"
}

variable "backend_domain" {
  type        = string
  description = "バックエンドのドメイン"
}
