output "db_endpoint" {
  value       = aws_db_instance.main.endpoint
  description = "Hostname:port the application connects to."
}

output "db_secret_arn" {
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
  description = "Secrets Manager ARN holding the auto-generated master password."
}

output "db_security_group_id" {
  value = aws_security_group.db.id
}