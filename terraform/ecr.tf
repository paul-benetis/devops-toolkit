# This setup allows GH Actions to connect to the ECR repository

module "iam_github_oidc_provider" {
  source = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"
}

module "iam_github_oidc_role" {
  depends_on = [module.iam_github_oidc_provider]

  source = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"

  subjects = ["${var.gh_account}/${var.gh_repo}:${var.gh_ref}"]

  policies = {
    ECRPullPush = aws_iam_policy.iam_github_oidc_ecr_access.arn
  }
}

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

  repository_name = var.gh_repo

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

provider "github" {
  owner = var.gh_account # Your GitHub username or organization
}

resource "github_actions_secret" "iam_github_oidc_role" {
  repository      = var.gh_repo
  secret_name     = "IAM_GITHUB_OIDC_ROLE"
  plaintext_value = module.iam_github_oidc_role.arn
}

resource "github_actions_secret" "aws_region" {
  repository      = var.gh_repo
  secret_name     = "AWS_REGION"
  plaintext_value = var.aws_region
}




# create policy for ecr and attach to role above
# create GH workflow in TF so you can reference role arn for GH to assume
# deploy workflow will need DOCKERFILE to build image before pushing to ecr
# add docs for bootstrapping GH workflow before terraform takes over
# example:
# gh repo clone <repo>
# gh repo create <repo> --public/private
# gh api \
#   -X PUT \
#   -H "Accept: application/vnd.github+json" \
#   /repos/<org>/<repo>/contents/.github/workflows/bootstrap.yml \
#   -f message='Bootstrap workflow' \
#   -f content="$(base64 -w 0 bootstrap.yml)"
