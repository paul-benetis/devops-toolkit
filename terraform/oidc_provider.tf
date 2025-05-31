module "iam_github_oidc_provider" {
  source = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"
}

module "iam_github_oidc_role" {
  depends_on = [module.iam_github_oidc_provider]

  source = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"

  subjects = [
  "${var.gh_account}/${var.gh_repo}:ref:${var.gh_ref}"]

  policies = {
    ECRPullPush          = aws_iam_policy.iam_github_oidc_ecr_access.arn,
    TerraformWriteAccess = aws_iam_policy.iam_github_oidc_terraform_write_access.arn
  }
}

module "iam_github_oidc_read_only_role" {
  depends_on = [module.iam_github_oidc_provider]

  source = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"

  subjects = [
    "${var.gh_account}/${var.gh_repo}:ref:refs/heads/*",
  "${var.gh_account}/${var.gh_repo}:pull_request"]

  policies = {
    ECRPullPush             = aws_iam_policy.iam_github_oidc_ecr_access.arn,
    TerraformReadOnlyAccess = aws_iam_policy.iam_github_oidc_terraform_read_only_access.arn
  }
}
