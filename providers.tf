terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" #  5.94.1"
    }
  }

  backend "s3" {
    bucket  = "cloudfix-2025"
    key     = "terraform/ClusterECS/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    profile = "CloudFix"
    # terraform state locks
    #dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
  default_tags {
    tags = local.common_tags
  }
}
