output "repository_url" {
  value       = aws_ecr_repository.main.repository_url
  description = "Push/pull URL for the ECR repository."
}

output "repository_arn" {
  value       = aws_ecr_repository.main.arn
  description = "ARN iam-oidc needs to scope its push policy to this repository specifically."
}