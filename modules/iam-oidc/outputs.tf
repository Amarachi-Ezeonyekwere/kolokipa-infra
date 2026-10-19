output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions_deploy.arn
  description = "Role kolokipa-app's CI workflow assumes to push to ECR and deploy to ECS."
}