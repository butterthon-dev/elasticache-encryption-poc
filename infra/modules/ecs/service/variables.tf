variable "name_prefix" {
  type        = string
  description = "ECSサービス名の接頭辞"
}

variable "retention_in_days" {
  type        = number
  description = "CloudWatchログの保持期間（日）。指定可能な値は0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653。0を選択した場合、ロググループ内のイベントは常に保持され期限切れにならない。log_group_classがDELIVERYに設定されている場合、この引数は無視され、retention_in_daysは強制的に2に設定される。"
  default     = 30
}

variable "requires_compatibilities" {
  type        = list(string)
  description = "ECSタスク定義の互換性"
  default     = ["FARGATE"]
}

variable "task_cpu" {
  type        = number
  description = "ECSタスク定義のCPU"
  default     = 256
}

variable "task_memory" {
  type        = number
  description = "ECSタスク定義のメモリ"
  default     = 512
}

variable "container_definitions" {
  type = list(object({
    name    = string
    image   = string
    command = optional(list(string))
    portMappings = optional(list(object({
      name          = string
      containerPort = number
      protocol      = string
    })))
    environment = optional(list(object({
      name  = string
      value = string
    })))
    secrets = optional(list(object({
      name      = string
      valueFrom = string
    })))
    essential              = bool
    readonlyRootFilesystem = optional(bool)
  }))
  description = "ECSタスク定義のコンテナ定義"
}

variable "desired_count" {
  type        = number
  description = "ECSサービスのタスク数"
  default     = 1
}

variable "ecs_service_name" {
  type        = string
  description = "ECSサービス名"
}

variable "cluster_id" {
  type        = string
  description = "ECSクラスターのID"
}

variable "cluster_name" {
  type        = string
  description = "ECSクラスター名"
}

variable "scheduling_strategy" {
  type        = string
  description = "ECSサービスのスケジューリング戦略"
  default     = "REPLICA"
}

variable "deployment_minimum_healthy_percent" {
  type        = number
  description = "デプロイ中にサービス内で実行され、正常な状態を維持する必要がある実行中のタスク数の下限(desired_countに対する割合)"
  default     = 100
}

variable "deployment_maximum_percent" {
  type        = number
  description = "デプロイ中にサービス内で実行可能なタスク数の上限(desired_countに対する割合)"
  default     = 200
}

variable "enable_execute_command" {
  type        = bool
  description = "ECS Exec Commandを有効にするかどうか。有効時はSSM Session Managerを通じてコンテナにshell接続が可能。デフォルトは無効(false)"
  default     = false
}

variable "health_check_grace_period_seconds" {
  type        = number
  description = "LB登録時のヘルスチェック猶予時間(秒)"
  default     = 60
}

variable "network_configuration" {
  type = object({
    subnet_ids         = list(string)
    assign_public_ip   = bool
    security_group_ids = list(string)
  })
  description = "ECSサービスのネットワーク設定"
}

variable "load_balancer" {
  type = object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  })
  description = "ECSサービスのロードバランサー設定"
  default     = null
}

variable "deployment_controller" {
  type = object({
    type = string
  })
  description = "ECSサービスのデプロイコントローラー設定"
  default = {
    type = "ECS"
  }
}

variable "deployment_circuit_breaker" {
  type = object({
    enable   = bool
    rollback = bool
  })
  description = "ECSサービスのサービスレジストリー設定"
  default = {
    enable   = true
    rollback = true
  }
}

variable "capacity_provider_strategy" {
  type = object({
    capacity_provider = string
    weight            = number
  })
  description = "キャパシティプロバイダー設定"
  default = {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }
}

variable "task_execution_role_arn" {
  type        = string
  description = "ECSタスク定義のタスク実行ロールARN"
}

variable "task_role_arn" {
  type        = string
  description = "ECSタスク定義のタスクロールARN"
}
