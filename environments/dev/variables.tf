variable "aws_region" {
  type        = string
  description = "AWS region to deploy into."
}

variable "name" {
  type        = string
  description = "Name prefix used to tag all resources in this environment."
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "One CIDR per public subnet/AZ."
}

variable "private_app_subnet_cidrs" {
  type        = list(string)
  description = "One CIDR per private app-tier subnet/AZ."
}

variable "private_db_subnet_cidrs" {
  type        = list(string)
  description = "One CIDR per private db-tier subnet/AZ."
}

variable "nextjs_port" {
  type        = number
  description = "Port the Next.js container listens on."
}

variable "springboot_port" {
  type        = number
  description = "Port the Spring Boot container listens on."
}

variable "db_username" {
  type        = string
  description = "Master username for the database."
}

variable "db_name" {
  type        = string
  description = "Name of the default database created on the instance."
}

variable "engine_version" {
  type        = string
  description = "Postgres version — confirm currently supported via `aws rds describe-db-engine-versions`."
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "github_org" {
  type        = string
  description = "name of the github account to connect with"
}

variable "app_repo_name" {
  type        = string
  description = "name of the app repo to connect with"

}