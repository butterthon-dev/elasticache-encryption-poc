output "vpc_id" {
  description = "VPCのID"
  value       = module.vpc.id
}

output "public_subnet_ids" {
  description = "パブリックサブネットのIDリスト"
  value       = [for public_subnet in module.public_subnets : public_subnet.id]
}

output "private_subnet_ids" {
  description = "プライベートサブネットのIDリスト"
  value       = [for private_subnet in module.private_subnets : private_subnet.id]
}

output "gateway_vpce_prefix_list_maps" {
  description = "Gateway VPC Endpointのプレフィックスリストのマップ（複数の CIDR ブロック（IPアドレス範囲）をまとめたもの）"
  value       = module.gateway_vpc_endpoint.prefix_list_maps
}
