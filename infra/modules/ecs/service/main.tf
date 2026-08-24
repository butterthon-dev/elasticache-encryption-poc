locals {
  region                     = data.aws_region.current.region
  ecs_service_name           = "${var.name_prefix}-service-${var.ecs_service_name}"
  ecs_task_definition_family = "${var.name_prefix}-taskdef-${var.ecs_service_name}"
  log_group_name             = "/aws/ecs/${var.cluster_name}/${local.ecs_service_name}"
  container_definitions_with_logging = [
    for container_definition in var.container_definitions : merge(
      container_definition,
      {
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.this.name
            awslogs-region        = local.region
            awslogs-stream-prefix = "ecs"
          }
        }
      }
    )
  ]
}

data "aws_region" "current" {}

# CloudWatchロググループ
#
# Note: CloudWatchログのInterface型VPCエンドポイントが必要
resource "aws_cloudwatch_log_group" "this" {
  name              = local.log_group_name
  retention_in_days = var.retention_in_days
}

# ECSタスク定義
resource "aws_ecs_task_definition" "this" {
  family                   = local.ecs_task_definition_family
  requires_compatibilities = var.requires_compatibilities
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions    = jsonencode(local.container_definitions_with_logging)

  tags = { Name = local.ecs_task_definition_family }
}

# ECSサービス
resource "aws_ecs_service" "this" {
  name            = local.ecs_service_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  # launch_type                        = "FARGATE" # launch_type と capacity_provider_strategyは両方指定できないのでlaunch_typeをコメントアウト
  platform_version                   = "LATEST"
  scheduling_strategy                = var.scheduling_strategy
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  enable_execute_command             = var.enable_execute_command
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds

  dynamic "capacity_provider_strategy" {
    for_each = [var.capacity_provider_strategy]
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
    }
  }

  dynamic "network_configuration" {
    for_each = [var.network_configuration]
    content {
      subnets          = network_configuration.value.subnet_ids
      assign_public_ip = network_configuration.value.assign_public_ip
      security_groups  = network_configuration.value.security_group_ids
    }
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer != null ? [var.load_balancer] : []
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  dynamic "deployment_controller" {
    for_each = [var.deployment_controller]
    content {
      type = deployment_controller.value.type
    }
  }

  dynamic "deployment_circuit_breaker" {
    for_each = [var.deployment_circuit_breaker]
    content {
      enable   = deployment_circuit_breaker.value.enable
      rollback = deployment_circuit_breaker.value.rollback
    }
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  tags = { Name = local.ecs_service_name }
}
