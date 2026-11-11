output "jwt_secret_arn" {
  value       = aws_secretsmanager_secret.jwt.arn
  description = "Secrets Manager ARN of the JWT signing key, injected into the backend task as JWT_SECRET."
}
