data "aws_route53_zone" "this" {
  name         = var.hosted_zone_name
  private_zone = false
}

module "ecs_cluster" {
  source = "../../modules/ecs/cluster"

  name_prefix = var.name_prefix
  name        = "main"
}

module "backend_task_role" {
  source = "../../modules/iam/roles/backend-task-role"

  name_prefix = var.name_prefix
}

# Djangoのシークレットキー
#
# 値はTerraformでは管理しない（プレースホルダーで作成し、実際の値はAWS CLIで投入する）。
#   aws ssm put-parameter --name <name> --type SecureString --value <secret> --overwrite
module "backend_django_secret" {
  source = "../../modules/ssm/parameter"

  name        = "/${var.name_prefix}/backend/django-secret"
  description = "Django SECRET_KEY for the backend service."
  type        = "SecureString"
  value       = "PLACEHOLDER"
}

module "backend_task_execution_role" {
  source = "../../modules/iam/roles/backend-task-execution-role"

  name_prefix        = var.name_prefix
  ssm_parameter_arns = [module.backend_django_secret.arn]
}

# Security Group Rules

module "backend_security_group" {
  source = "../../modules/network/security-group"

  name_prefix = var.name_prefix
  name        = "backend-service"
  description = "Security group for Backend Service."
  vpc_id      = var.vpc_id
}

module "internal_ingress_to_backend_service" {
  source = "../../modules/network/security-group-ingress-rule"

  security_group_id = module.backend_security_group.id
  description       = "App port from VPC"
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = 8000
  to_port           = 8000
  ip_protocol       = "tcp"
}

module "backend_service_to_interface_vpce" {
  source = "../../modules/network/security-group-egress-rule"

  security_group_id = module.backend_security_group.id
  description       = "HTTPS to VPC (interface endpoints)"
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# public.ecr.aws（ECR Public）にはVPCエンドポイントが存在しないため、
# ダミーイメージの取得はNAT Gateway経由のインターネット通信で行う。
# アプリのイメージはプライベートECR + Interface/Gateway Endpoint経由で取得する。
module "backend_service_to_internet" {
  source = "../../modules/network/security-group-egress-rule"

  security_group_id = module.backend_security_group.id
  description       = "HTTPS to Internet (ECR Public) via NAT Gateway"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

module "backend_service_to_gateway_vpce" {
  source = "../../modules/network/security-group-egress-rule"

  for_each = var.gateway_vpce_prefix_list_maps

  security_group_id = module.backend_security_group.id
  description       = "HTTPS to ${each.key} gateway endpoint"
  prefix_list_id    = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}


# ALB

module "backend_alb_security_group" {
  source = "../../modules/network/security-group"

  name_prefix = var.name_prefix
  name        = "backend-alb"
  description = "Security group for Backend Application Load Balancer."
  vpc_id      = var.vpc_id
}

module "backend_alb" {
  source = "../../modules/alb/load-balancer"

  name_prefix        = var.name_prefix
  name               = "backend"
  internal           = false
  subnet_ids         = var.public_subnet_ids
  security_group_ids = [module.backend_alb_security_group.id]
}

module "backend_alb_target_group" {
  source = "../../modules/alb/target-group"

  name_prefix       = var.name_prefix
  name              = "backend"
  vpc_id            = var.vpc_id
  target_type       = "ip"
  port              = 8000
  protocol          = "HTTP"
  health_check_path = "/healthz"
}

module "backend_alb_alias" {
  source = "../../modules/route53/record"

  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.backend_domain
  type    = "A"

  alias = {
    name                   = module.backend_alb.dns_name
    zone_id                = module.backend_alb.zone_id
    evaluate_target_health = false
  }
}

# ACM Certificate (DNS検証)

module "backend_certificate" {
  source = "../../modules/acm/certificate"

  domain_name = var.backend_domain
}

# モジュール名がすぐ下にある"backend_certificate_validation"と同じなので、変えたい（検証リポジトリなので、一旦このまま進める）
module "backend_cert_validation" {
  # backend_certificate（ACM証明書）のDNS検証用レコード
  source = "../../modules/route53/record"

  count   = length(module.backend_certificate.domain_validation_options)
  zone_id = data.aws_route53_zone.this.zone_id
  name    = module.backend_certificate.domain_validation_options[count.index].name
  type    = module.backend_certificate.domain_validation_options[count.index].type
  ttl     = 60
  records = [module.backend_certificate.domain_validation_options[count.index].value]
}

module "backend_certificate_validation" {
  source = "../../modules/acm/certificate-validation"

  certificate_arn = module.backend_certificate.arn
}

# HTTP listener (80)

module "backend_http_listener" {
  source = "../../modules/alb/listener"

  load_balancer_arn                  = module.backend_alb.arn
  port                               = 80
  protocol                           = "HTTP"
  default_action_type                = "redirect"
  default_redirect_protocol          = "HTTPS"
  default_redirect_port              = "443"
  default_redirect_status_code       = "HTTP_301"
  default_fixed_response_status_code = "403"
  default_fixed_response_body        = "Forbidden"
}

module "backend_http_host_header_rule" {
  source = "../../modules/alb/listener-rule"

  listener_arn     = module.backend_http_listener.arn
  priority         = 1
  target_group_arn = module.backend_alb_target_group.arn
  host_headers     = [var.backend_domain]
}

# # HTTPS listener (443)

module "backend_https_listener" {
  source = "../../modules/alb/listener"

  load_balancer_arn = module.backend_alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = module.backend_certificate_validation.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action_type                = "fixed-response"
  default_fixed_response_status_code = "403"
  default_fixed_response_body        = "Forbidden"
}

module "https_host_header_rule" {
  source = "../../modules/alb/listener-rule"

  listener_arn     = module.backend_https_listener.arn
  priority         = 1
  target_group_arn = module.backend_alb_target_group.arn
  host_headers     = [var.backend_domain]
}


# ECS

module "backend_service" {
  source = "../../modules/ecs/service"

  name_prefix             = var.name_prefix
  cluster_id              = module.ecs_cluster.id
  cluster_name            = module.ecs_cluster.name
  task_role_arn           = module.backend_task_role.arn
  task_execution_role_arn = module.backend_task_execution_role.arn
  ecs_service_name        = "backend"
  network_configuration = {
    assign_public_ip   = false
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [module.backend_security_group.id]
  }
  container_definitions = [
    {
      name                   = "api"
      image                  = "public.ecr.aws/docker/library/alpine:latest"
      command                = ["tail", "-f", "/dev/null"] # コンテナを実行し続けるコマンド
      essential              = true
      readonlyRootFilesystem = false
      portMappings = [
        {
          name          = "api"
          containerPort = 8000
          protocol      = "tcp"
        }
      ]
    }
  ]
  load_balancer = {
    target_group_arn = module.backend_alb_target_group.arn
    container_name   = "api"
    container_port   = 8000
  }
}
