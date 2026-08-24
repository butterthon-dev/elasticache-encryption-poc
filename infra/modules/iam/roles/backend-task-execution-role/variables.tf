variable "name_prefix" {
  type        = string
  description = "ロール名の接頭辞"
}

variable "ssm_parameter_arns" {
  type        = list(string)
  description = "コンテナ定義のsecretsから参照するSSMパラメータのARNリスト"
  default     = []
}
