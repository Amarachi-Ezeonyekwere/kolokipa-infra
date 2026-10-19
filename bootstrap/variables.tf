variable "aws_region" {
  type        = string
  description = "AWS region to create the state bucket and lock table in."
}

variable "state_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name — convention is <project>-tfstate-<aws-account-id>."
}

variable "lock_table_name" {
  type        = string
  description = "DynamoDB table name for Terraform state locking."
}