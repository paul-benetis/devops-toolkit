terraform {
  required_version = "1.11.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.95.0"
    }
  }
}

provider "aws" {
  shared_config_files      = ["/Users/paulbenetis/.aws/config"]
  shared_credentials_files = ["/Users/paulbenetis/.aws/credentials"]
  profile                  = "default"
}