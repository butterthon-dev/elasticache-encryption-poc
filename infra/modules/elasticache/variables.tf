variable "env" {
  type        = string
  description = "環境名"
}

variable "name_prefix" {
  description = "Elasticacheリソース名のプレフィックス"
}

variable "name" {
  description = "Elasticacheリソース名"
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "ElasticacheにアタッチするセキュリティグループのVPC ID"
}

variable "egress_rules" {
  type = list(object({
    description        = optional(string)
    security_group_ids = optional(list(string))
    from_port          = number
    to_port            = number
    protocol           = string
    cidr_blocks        = optional(list(string))
    security_groups    = optional(list(string))
  }))
  description = "Elasticacheにアタッチするセキュリティグループのアウトバウンドルール"
  default = [{
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = []
  }]
}

variable "ingress_rules" {
  type = list(object({
    description        = optional(string)
    security_group_ids = optional(list(string))
    from_port          = number
    to_port            = number
    protocol           = string
    cidr_blocks        = optional(list(string))
    security_groups    = optional(list(string))
  }))
  description = "Elasticacheにアタッチするセキュリティグループのインバウンドルール"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Elasticache配置先のサブネットID"
}

variable "description" {
  type        = string
  description = "ElasticacheのReplication Groupの説明"
  default     = "Elasticache Cluster"
}

variable "cluster_mode" {
  type        = string
  description = "クラスタ・モードが有効か無効かを指定。有効な値はenabled, disabled, compatible。デフォルトは無効（disabled）"
  default     = "disabled"
}

variable "engine" {
  type        = string
  description = "Elasticacheのエンジン"
  default     = "redis"
}

variable "node_type" {
  type        = string
  description = "Elasticacheのノードタイプ"
  default     = "cache.t2.micro"
}

variable "engine_version" {
  type        = string
  description = "使用するキャッシュ・エンジンのバージョン番号。設定されていない場合は最新バージョンになります。"
  default     = null
}

variable "parameter_group_name" {
  type        = string
  description = "このレプリケーショングループに関連付けるパラメータグループ名。この引数を省略すると、指定したエンジンのデフォルトのキャッシュパラメータグループが指定されます。"
  default     = null
}

variable "port" {
  type        = number
  description = "各キャッシュノードが接続を受け付けるポート番号。Memcacheのデフォルトは11211、Redisのデフォルトは6379"
}

variable "apply_immediately" {
  type        = bool
  description = "データベースの変更を即時適用するか、または次のメンテナンスウィンドウ中に適用するかを指定"
  default     = false
}

variable "transit_encryption_enabled" {
  type        = bool
  description = "転送中の暗号化を有効にする"
  default     = false
}

variable "at_rest_encryption_enabled" {
  type        = bool
  description = "保存時の暗号化を有効にする（AWS管理キーを使用）"
  default     = false
}

variable "automatic_failover_enabled" {
  type        = bool
  description = "プライマリに障害が発生した場合、読み取り専用レプリカを読み取り/書き込みプライマリに自動的に昇格させるかどうか"
  default     = false
}

variable "num_node_groups" {
  type        = number
  description = "Redisレプリケーション・グループのノード・グループ（シャード）の数"
  default     = 1
}

variable "replicas_per_node_group" {
  type        = number
  description = "各ノードグループのレプリカノード数。有効な値は0から5。"
  default     = 0
}

variable "slow_log_format" {
  type        = string
  description = "Redis SLOWLOGのログフォーマット"
  default     = "json"
}

variable "engine_log_format" {
  type        = string
  description = "Redis Engine Logのログフォーマット"
  default     = "json"
}

variable "log_delivery_configurations" {
  type = list(object({
    destination      = string
    destination_type = string
    log_format       = string
    log_type         = string
  }))
  description = "Redis SLOWLOGまたはRedis Engine LogをCloudWatch LogsまたはKinesis Data Firehoseにストリーミングする設定"
  default     = []
}

variable "tags" {
  description = "リソースに適用するタグのマップ"
  type        = map(string)
  default     = {}
}

variable "retention_in_days" {
  type        = number
  description = "CloudWatchログの保持期間（日）。指定可能な値は0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653。0を選択した場合、ロググループ内のイベントは常に保持され期限切れにならない。log_group_classがDELIVERYに設定されている場合、この引数は無視され、retention_in_daysは強制的に2に設定される。"
  default     = 30
}

variable "snapshot_retention_limit" {
  type        = number
  description = "ElastiCacheが自動キャッシュクラスタスナップショットを削除するまでの保持日数"
  default     = 1
}

variable "snapshot_window" {
  type        = string
  description = "ElastiCacheがキャッシュクラスタのデイリースナップショットの取得を開始する時間帯（UTC）"
  default     = "18:00-19:00" // 3:00-4:00(JST)
}
