resource "aws_ecr_repository" "main" {
  name                 = "${var.name}-ecr"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true # lets the destroy workflow remove the repo even when it still holds images

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.name}-ecr"
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 14 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 14
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Keep only the 10 newest backend images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["backend-"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 3
        description  = "Keep only the 10 newest frontend images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["frontend-"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = { type = "expire" }
      }
    ]
  })
}

resource "aws_ssm_parameter" "ecr_repo_uri" {
  name  = "/${var.name}/ecr-repo-uri"
  type  = "String"
  value = aws_ecr_repository.main.repository_url

  tags = {
    Name = "${var.name}-ecr-repo-uri"
  }
}
