resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.name}-ecs-tasks-sg"
  description = "Allows traffic from the ALB to ECS Fargate tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.nextjs_port
    to_port         = var.nextjs_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  ingress {
    from_port       = var.springboot_port
    to_port         = var.springboot_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  # Task-to-task: the Next.js server calls the backend over private DNS.
  ingress {
    description = "Frontend tasks reach backend tasks directly"
    from_port   = var.springboot_port
    to_port     = var.springboot_port
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    #tfsec:ignore:aws-ec2-no-public-egress-sgr
    cidr_blocks = ["0.0.0.0/0"] # scoped in practice by the private route table — no internet path exists regardless
  }

  tags = {
    Name = "${var.name}-ecs-tasks-sg"
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.name}"
  retention_in_days = var.log_retention_days
}
