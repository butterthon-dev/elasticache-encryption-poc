output "arn" {
  description = "ECRリポジトリのARN"
  value       = aws_ecr_repository.this.arn
}

output "name" {
  description = "ECRリポジトリ名"
  value       = aws_ecr_repository.this.name
}

output "repository_url" {
  description = "ECRリポジトリのURL"
  value       = aws_ecr_repository.this.repository_url
}
