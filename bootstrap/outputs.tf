output "state_bucket_name" {
  value       = aws_s3_bucket.tf_state.bucket
  description = "Copy this into environments/dev/backend.tf's bucket field."
}

output "lock_table_name" {
  value       = aws_dynamodb_table.tf_lock.name
  description = "Copy this into environments/dev/backend.tf's dynamodb_table field."
}