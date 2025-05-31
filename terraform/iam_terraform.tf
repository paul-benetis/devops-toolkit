resource "aws_iam_policy" "iam_github_oidc_terraform_write_access" {
  name        = "GitHubOIDCTerraformWriteAccess"
  description = "Allows GitHub OIDC Role to deploy resources via Terraform"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:List*",
          "s3:Get*",
          "s3:PutObject",
          "s3:DeleteObject",
        ],
        "Resource" : [
          "arn:aws:s3:::paulb-devops-toolkit-terraform-state",
          "arn:aws:s3:::paulb-devops-toolkit-terraform-state/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:*",
          "iam:*",
          "ecr:*",
          "ecs:*",
          "logs:*",
          "cloudwatch:*",
          "lambda:*",
          "apigateway:*",
          "sqs:*",
          "sns:*"
        ],
        "Resource" : "*"
      },
    ]
  })
}

resource "github_actions_secret" "iam_github_oidc_role" {
  repository      = var.gh_repo
  secret_name     = "IAM_GITHUB_OIDC_ROLE"
  plaintext_value = module.iam_github_oidc_role.arn
}

resource "aws_iam_policy" "iam_github_oidc_terraform_read_only_access" {
  name        = "GitHubOIDCTerraformReadOnlyAccess"
  description = "Allows GitHub OIDC Role to plan resources via Terraform"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:List*",
          "s3:Get*",
          "s3:PutObject",
          "s3:DeleteObject",
        ],
        "Resource" : [
          "arn:aws:s3:::paulb-devops-toolkit-terraform-state",
          "arn:aws:s3:::paulb-devops-toolkit-terraform-state/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:Describe*",
          "iam:Get*",
          "iam:List*",
          "ecr:Describe*",
          "ecr:Get*",
          "ecs:Describe*",
          "ecs:List*",
          "logs:Describe*",
          "logs:Get*",
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "lambda:List*",
          "lambda:Get*",
          "lambda:InvokeFunction",
          "apigateway:GET",
          "sqs:Get*",
          "sqs:List*",
          "sns:Get*",
          "sns:List*"
        ],
        Resource = "*"
      },
    ]
  })
}

resource "github_actions_secret" "iam_github_oidc_read_only_role" {
  repository      = var.gh_repo
  secret_name     = "IAM_GITHUB_OIDC_READ_ONLY_ROLE"
  plaintext_value = module.iam_github_oidc_read_only_role.arn
}
