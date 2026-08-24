locals {
  region = data.aws_region.current.region
}

data "aws_region" "current" {}

module "vpc" {
  source = "../../modules/network/vpc"

  name_prefix = var.name_prefix
  cidr_block  = var.vpc_cidr_block
}

module "internet_gateway" {
  source = "../../modules/network/internet-gateway"

  name_prefix = var.name_prefix
  vpc_id      = module.vpc.id
}

module "public_subnets" {
  source = "../../modules/network/subnet"

  for_each = var.public_subnets

  name_prefix       = "${var.name_prefix}-${each.key}-public"
  vpc_id            = module.vpc.id
  cidr_block        = each.value
  availability_zone = each.key
}

module "public_subnet_rtb" {
  source = "../../modules/network/route-table"

  name_prefix            = var.name_prefix
  vpc_id                 = module.vpc.id
  association_subnet_ids = [for public_subnet in module.public_subnets : public_subnet.id]
  routes = [{
    cidr_block = "0.0.0.0/0"
    gateway_id = module.internet_gateway.id
  }]
}

# リージョナルNat Gateway
module "nat_gateway" {
  source = "../../modules/network/nat-gateway"

  name_prefix = var.name_prefix
  vpc_id      = module.vpc.id
}

module "private_subnets" {
  source = "../../modules/network/subnet"

  for_each = var.private_subnets

  name_prefix       = "${var.name_prefix}-${each.key}-private"
  vpc_id            = module.vpc.id
  cidr_block        = each.value
  availability_zone = each.key
}

module "private_subnet_rtb" {
  source = "../../modules/network/route-table"

  name_prefix            = var.name_prefix
  vpc_id                 = module.vpc.id
  association_subnet_ids = [for private_subnet in module.private_subnets : private_subnet.id]
  routes = [{
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = module.nat_gateway.id
  }]
}

# Security Groups

module "vpce_sg" {
  source = "../../modules/network/security-group"

  name_prefix = var.name_prefix
  name        = "vpce"
  description = "Security group for VPC endpoints"
  vpc_id      = module.vpc.id
}

# Security Group Rules

module "vpce_https_ingress" {
  source = "../../modules/network/security-group-ingress-rule"

  security_group_id = module.vpce_sg.id
  description       = "HTTPS from VPC"
  cidr_ipv4         = module.vpc.cidr_block
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# VPC Endpoints

module "gateway_vpc_endpoint" {
  source = "../../modules/network/gateway-vpc-endpoint"

  region         = data.aws_region.current.region
  vpc_id         = module.vpc.id
  route_table_id = module.private_subnet_rtb.id
}

module "interface_vpc_endpoint" {
  source = "../../modules/network/interface-vpc-endpoint"

  region             = local.region
  vpc_id             = module.vpc.id
  subnet_ids         = [for private_subnet in module.private_subnets : private_subnet.id]
  security_group_ids = [module.vpce_sg.id]
}
