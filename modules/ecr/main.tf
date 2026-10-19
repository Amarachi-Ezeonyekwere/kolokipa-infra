resource "aws_ecr_repository" "main" {
  name                 = "${var.name}-ecr"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.name}-ecr"
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire images older than 14 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 14
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

resource "aws_ssm_parameter" "ecr_repo_uri" {
  name  = "/${var.name}/ecr-repo-uri"
  type  = "String"
  value = aws_ecr_repository.main.repository_url

  tags = {
    Name = "${var.name}-ecr-repo-uri"
  }
}