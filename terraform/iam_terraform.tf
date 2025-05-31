resource "aws_iam_policy" "iam_github_oidc_terraform_access" {
  name        = "GitHubOIDCTerraformAccess"
  description = "Allows GitHub OIDC Role to deploy resources via Terraform"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
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
