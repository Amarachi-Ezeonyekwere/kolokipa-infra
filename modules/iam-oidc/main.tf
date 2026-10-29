# main.tf
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "github_actions_deploy" {
  name = "${var.name}-github-actions-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = ["sts:AssumeRoleWithWebIdentity", "sts:TagSession"]
      Principal = { Federated = data.aws_iam_openid_connect_provider.github.arn }
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.app_repo_name}:ref:refs/heads/main"
        }
      }
    }]
  })

  tags = {
    Name = "${var.name}-github-actions-deploy"
  }
}

resource "aws_iam_role_policy" "github_actions_deploy" {
  name = "${var.name}-github-actions-deploy-policy"
  role = aws_iam_role.github_actions_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid      = "ECRAuth"
          Effect   = "Allow"
          Action   = "ecr:GetAuthorizationToken"
          Resource = "*"
        },
        {
          Sid    = "ECRPush"
          Effect = "Allow"
          Action = [
            "ecr:BatchCheckLayerAvailability",
            "ecr:PutImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "ecr:BatchGetImage",
          ]
          Resource = var.ecr_repository_arn
        },
        {
          Sid    = "ECSDeploy"
          Effect = "Allow"
          Action = [
            "ecs:RegisterTaskDefinition",
            "ecs:DescribeTaskDefinition",
            "ecs:UpdateService",
            "ecs:DescribeServices",
          ]
          Resource = "*"
        },
        {
          Sid      = "ReadSsmParams"
          Effect   = "Allow"
          Action   = "ssm:GetParameter"
          Resource = "arn:aws:ssm:*:*:parameter/${var.name}/*"
        },
      ],
      length(var.ecs_task_role_arns) > 0 ? [
        {
          Sid      = "PassTaskRoles"
          Effect   = "Allow"
          Action   = "iam:PassRole"
          Resource = var.ecs_task_role_arns
        }
      ] : []
    )
  })
}