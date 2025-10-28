terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket  = "cloudfix-2025"
    key     = "terraform/ClusterECS/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    # Profile usado apenas quando definido (local)
    profile = var.aws_profile != "" ? var.aws_profile : null
  }
}

provider "aws" {
  region = var.region
  # Profile usado apenas quando definido (local)
  profile = var.aws_profile != "" ? var.aws_profile : null

  default_tags {
    tags = local.common_tags
  }
}
