variable "service_name" {
  type        = string
  description = "Name of the ECS service; also the task definition family."
}

variable "cluster_id" {
  type        = string
  description = "ECS cluster the service runs in."
}

variable "container_name" {
  type        = string
  description = "Container name; must match the load balancer registration."
}

variable "container_image" {
  type        = string
  description = "Placeholder image for the first task definition. The pipeline replaces it on every release."
}

variable "container_port" {
  type        = number
  description = "Port the container listens on."
}

variable "cpu" {
  type        = number
  description = "Fargate CPU units (256, 512, 1024, ...)."
}

variable "memory" {
  type        = number
  description = "Fargate memory in MiB; must be a valid pairing for the CPU value."
}

variable "execution_role_arn" {
  type        = string
  description = "Task execution role ARN."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnets the tasks run in."
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security groups attached to the tasks."
}

variable "target_group_arn" {
  type        = string
  description = "ALB target group the service registers its tasks into."
}

variable "health_check_grace_period_seconds" {
  type        = number
  description = "How long ECS ignores failing ALB health checks while a new task starts."
}

variable "log_group_name" {
  type        = string
  description = "CloudWatch log group for container logs."
}

variable "aws_region" {
  type        = string
  description = "Region used by the awslogs driver."
}

variable "environment" {
  type        = map(string)
  default     = {}
  description = "Plain environment variables."
}

variable "secrets" {
  type        = map(string)
  default     = {}
  description = "Environment variable name to Secrets Manager reference."
}

variable "service_registry_arn" {
  type        = string
  default     = null
  description = "Cloud Map service ARN to register tasks into. Null means no private DNS name."
}
