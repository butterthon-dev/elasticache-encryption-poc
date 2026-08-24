output "arn" {
  value = aws_iam_role.this.arn
}

output "name" {
  description = "タスク実行ロール名"
  value       = aws_iam_role.this.name
}
