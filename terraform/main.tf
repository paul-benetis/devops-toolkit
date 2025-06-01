terraform {
  required_version = "1.11.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.95.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "paulb-devops-toolkit-terraform-state"
    key          = "tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project = "devops-toolkit"
    }
  }
}

provider "github" {
  owner = var.gh_account # Your GitHub username or organization
}

resource "github_actions_secret" "aws_region" {
  repository      = var.gh_repo
  secret_name     = "AWS_REGION"
  plaintext_value = var.aws_region
}

resource "github_actions_secret" "app_name" {
  repository      = var.gh_repo
  secret_name     = "APP_NAME"
  plaintext_value = var.app_name
}
