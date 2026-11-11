
resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = "${var.name}.internal"
  description = "Private DNS namespace for service-to-service calls."
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "backend" {
  name          = "backend"
  force_destroy = true # lets terraform destroy succeed even if a task has not deregistered yet

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.this.id
    routing_policy = "MULTIVALUE"

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
