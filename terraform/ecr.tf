resource "aws_iam_policy" "iam_github_oidc_ecr_access" {
  name        = "GitHubOIDCECRAccess"
  description = "Allows GitHub OIDC Role to push/pull images from ECR"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = module.ecr.repository_arn
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}

# ECR specific resources below
module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "${var.gh_account}/${var.gh_repo}"

  repository_read_write_access_arns = [module.iam_github_oidc_role.arn]

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_repository_policy" "allow_pull_push" {
  repository = module.ecr.repository_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPullForAnyone"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      },
      {
        Sid    = "AllowPushForSpecificRole"
        Effect = "Allow"
        Principal = {
          AWS = module.iam_github_oidc_role.arn
        }
        Action = [
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}
