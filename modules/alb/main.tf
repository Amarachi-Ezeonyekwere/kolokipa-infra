
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Allows HTTP from the internet to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "${var.name}-alb-sg"
  }
}

resource "aws_lb" "main" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  # Access logs deferred: requires an S3 bucket plus a bucket policy
  # granting the region's ELB service account write access. Revisit
  # once the observability pass covers this properly.

  tags = {
    Name = "${var.name}-alb"
  }
}

resource "aws_lb_target_group" "nextjs" {
  name        = "${var.name}-nextjs-tg"
  port        = var.nextjs_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # required for Fargate — tasks have no fixed EC2 instance to register against

  health_check {
    path                = var.nextjs_health_check_path
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "${var.name}-nextjs-tg"
  }
}

resource "aws_lb_target_group" "springboot" {
  name        = "${var.name}-springboot-tg"
  port        = var.springboot_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.springboot_health_check_path
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "${var.name}-springboot-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  # Catch-all: anything not matched by a more specific rule below
  # goes to Next.js.
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nextjs.arn
  }
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.springboot.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}