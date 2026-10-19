variable "name" {
  type        = string
  description = "Name prefix used to tag resources created by this module."
}

variable "vpc_id" {
  type        = string
  description = "VPC to create the ALB and its target groups in."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs the ALB is deployed into — from the networking module's output."
}

variable "nextjs_port" {
  type        = number
  description = "Port the Next.js container listens on."
}

variable "nextjs_health_check_path" {
  type        = string
  default     = "/"
  description = "Health check path for the Next.js target group."
}

variable "springboot_port" {
  type        = number
  description = "Port the Spring Boot container listens on."
}

variable "springboot_health_check_path" {
  type        = string
  default     = "/api/actuator/health"
  description = "Health check path for the Spring Boot target group."
}

variable "enable_deletion_protection" {
  type        = bool
  default     = false
  description = "Set true once this is a real production environment — blocks accidental terraform destroy."
}