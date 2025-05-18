data "aws_caller_identity" "current" {}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "gh_account" {
  description = "GitHub account"
  type        = string
}
variable "gh_repo" {
  description = "GitHub repository"
  type        = string
}
variable "gh_ref" {
  description = "GitHub reference"
  type        = string
}
