# SSMパラメータストアのパラメータ
#
# SecureStringの場合、valueはtfstateに平文で保存される。
# そのためTerraformではプレースホルダー値のみを登録し、実際の値はAWS CLI等で投入する運用を前提に
# lifecycle.ignore_changesでvalueの差分を無視する。
resource "aws_ssm_parameter" "this" {
  name        = var.name
  description = var.description
  type        = var.type
  value       = var.value
  tier        = var.tier

  lifecycle {
    ignore_changes = [value]
  }

  tags = { Name = var.name }
}
