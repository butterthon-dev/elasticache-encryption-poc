output "arn" {
  description = "GitHub Actionsデプロイ用ロールのARN"
  value       = aws_iam_role.this.arn
}

output "name" {
  description = "GitHub Actionsデプロイ用ロール名"
  value       = aws_iam_role.this.name
}
