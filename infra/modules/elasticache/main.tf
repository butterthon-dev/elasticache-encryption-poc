
resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.name_prefix}-log-${var.name}"
  retention_in_days = var.retention_in_days
  tags              = var.tags
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name_prefix}-subnetg-${var.name}"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "this" {
  name   = "${var.name_prefix}-sg-${var.name}"
  vpc_id = var.vpc_id

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      security_groups = try(egress.value.security_groups, null)
      cidr_blocks     = try(egress.value.cidr_blocks, null)
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
    }
  }

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      security_groups = try(ingress.value.security_groups, null)
      cidr_blocks     = try(ingress.value.cidr_blocks, null)
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-sg-${var.name}"
  })
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id       = "${var.name_prefix}-elasticache-${var.name}"
  description                = var.description
  cluster_mode               = var.cluster_mode
  node_type                  = var.node_type
  engine                     = var.engine
  parameter_group_name       = var.parameter_group_name
  engine_version             = var.engine_version
  port                       = var.port
  automatic_failover_enabled = var.automatic_failover_enabled
  num_node_groups            = var.num_node_groups
  replicas_per_node_group    = var.replicas_per_node_group
  security_group_ids         = [aws_security_group.this.id]
  subnet_group_name          = aws_elasticache_subnet_group.this.name
  apply_immediately          = var.apply_immediately
  transit_encryption_enabled = var.transit_encryption_enabled
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  snapshot_retention_limit   = var.snapshot_retention_limit
  snapshot_window            = var.snapshot_window
  snapshot_name              = var.snapshot_name

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.this.name
    destination_type = "cloudwatch-logs"
    log_format       = var.slow_log_format
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.this.name
    destination_type = "cloudwatch-logs"
    log_format       = var.engine_log_format
    log_type         = "engine-log"
  }

  dynamic "log_delivery_configuration" {
    for_each = var.log_delivery_configurations
    content {
      destination      = log_delivery_configuration.value.destination
      destination_type = log_delivery_configuration.value.destination_type
      log_format       = log_delivery_configuration.value.log_format
      log_type         = log_delivery_configuration.value.log_type
    }
  }

  # Elasticacheを復元した後はignore_changesのコメントアウトを解除して、呼び出し側のsnapshot_nameを行ごと削除
  lifecycle {
    ignore_changes = [snapshot_name]
  }

  tags = var.tags
}

resource "aws_ssm_parameter" "primary_endpoint" {
  count = var.cluster_mode == "disabled" ? 1 : 0

  name        = "/${replace(var.name_prefix, "${var.env}-", "${var.env}/")}/elasticache/${var.name}/primary_endpoint"
  description = var.description
  type        = "SecureString"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
  tier        = "Standard"
  tags        = { Name = var.name }
}

resource "aws_ssm_parameter" "reader_endpoint" {
  count = var.cluster_mode == "disabled" ? 1 : 0

  name        = "/${replace(var.name_prefix, "${var.env}-", "${var.env}/")}/elasticache/${var.name}/reader_endpoint"
  description = var.description
  type        = "SecureString"
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
  tier        = "Standard"
  tags        = { Name = var.name }
}

resource "aws_ssm_parameter" "configuration_endpoint" {
  count = var.cluster_mode == "enabled" ? 1 : 0

  name        = "/${replace(var.name_prefix, "${var.env}-", "${var.env}/")}/elasticache/${var.name}/configuration_endpoint"
  description = var.description
  type        = "SecureString"
  value       = aws_elasticache_replication_group.this.configuration_endpoint_address
  tier        = "Standard"
  tags        = { Name = var.name }
}
