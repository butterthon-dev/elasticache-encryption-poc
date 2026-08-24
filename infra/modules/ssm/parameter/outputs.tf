output "arn" {
  description = "パラメータのARN"
  value       = aws_ssm_parameter.this.arn
}

output "name" {
  description = "パラメータ名"
  value       = aws_ssm_parameter.this.name
}
