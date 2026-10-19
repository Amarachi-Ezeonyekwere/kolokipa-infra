variable "name" {
  type        = string
  description = "Name prefix used to tag resources created by this module."
}

variable "vpc_id" {
  type        = string
  description = "VPC to create the db and subnets in."
}

variable "private_db_subnet_ids" {
  type        = list(string)
  description = "Private DB-tier subnet IDs from the networking module's output."
}

variable "ecs_tasks_security_group_id" {
  type        = string
  description = "Security group of the ECS tasks — the only source allowed to reach the database."
}

variable "username" {
  type        = string
  description = "Master username for the database."
}

variable "db_name" {
  type        = string
  description = "Name of the default database created on the instance."
}

variable "engine_version" {
  type        = string
  description = "Postgres version — confirm it's currently supported via `aws rds describe-db-engine-versions` before setting this."
}

variable "instance_class" {
  type        = string
  default     = "db.t3.micro" # free-tier eligible: 750 hrs/month for 12 months, single-AZ only
  description = "RDS instance class."
}

variable "allocated_storage" {
  type        = number
  default     = 20 # GB — within the free-tier allowance
  description = "Allocated storage in GB."
}

variable "multi_az" {
  type        = bool
  default     = false
  description = "Multi-AZ doubles instance cost (synchronous standby). Leave false until this is production."
}

variable "skip_final_snapshot" {
  type        = bool
  default     = true
  description = "Dev-friendly default — set false before this is ever production data."
}

variable "deletion_protection" {
  type        = bool
  default     = false
  description = "Dev-friendly default — set true before this is ever production data."
}