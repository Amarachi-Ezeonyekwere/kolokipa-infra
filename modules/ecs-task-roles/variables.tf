variable "name" {
  type        = string
  description = "Name prefix used to name resources created by this module."
}

variable "secret_arns" {
  type        = list(string)
  description = "Secrets Manager ARNs the task execution role may read (JWT secret and the RDS master secret)."
}
