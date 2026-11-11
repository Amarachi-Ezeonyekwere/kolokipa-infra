output "backend_service_arn" {
  value       = aws_service_discovery_service.backend.arn
  description = "Registry ARN the backend ECS service registers its tasks into."
}

output "backend_dns_name" {
  value       = "backend.${aws_service_discovery_private_dns_namespace.this.name}"
  description = "Private DNS name the frontend uses to reach the backend."
}
