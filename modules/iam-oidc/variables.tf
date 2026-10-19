variable "name" {
  type        = string
  description = "Name prefix used to tag resources and name the IAM role."
}

variable "github_org" {
  type        = string
  description = "GitHub username or org — scopes the OIDC trust to only this account."
}

variable "app_repo_name" {
  type        = string
  description = "Name of the application repo whose main-branch workflow is allowed to assume this role."
}

variable "ecr_repository_arn" {
  type        = string
  description = "ARN of the ECR repository this role is allowed to push to."
}

variable "ecs_task_role_arns" {
  type        = list(string)
  default     = []
  description = "ARNs of ECS task/execution roles this role can pass to ECS. Empty until the ECS service's task roles exist."
}