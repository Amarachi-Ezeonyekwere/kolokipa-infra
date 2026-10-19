variable "name" {
  type        = string
  description = "Name prefix used to tag resources created by this module."
}

variable "vpc_id" {
  type        = string
  description = "VPC the ECS tasks security group is created in."
}

variable "alb_security_group_id" {
  type        = string
  description = "Security group of the ALB — the only source allowed to reach ECS tasks."
}

variable "nextjs_port" {
  type        = number
  description = "Port the Next.js container listens on."
}

variable "springboot_port" {
  type        = number
  description = "Port the Spring Boot container listens on."
}

variable "log_retention_days" {
  type        = number
  default     = 30
  description = "CloudWatch Logs retention for ECS container logs."
}