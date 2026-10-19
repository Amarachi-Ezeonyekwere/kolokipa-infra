variable "name" {
  type        = string
  description = "Name prefix used to tag resources created by this module."
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC, e.g. 10.0.0.0/16."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "One CIDR block per public subnet/AZ."
}

variable "private_app_subnet_cidrs" {
  type        = list(string)
  description = "One CIDR block per private app-tier subnet/AZ."
}

variable "private_db_subnet_cidrs" {
  type        = list(string)
  description = "One CIDR block per private db-tier subnet/AZ."
}

variable "flow_log_retention_days" {
  type        = number
  default     = 30
  description = "CloudWatch Logs retention for VPC Flow Logs."
}