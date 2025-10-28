terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" #  5.94.1"
    }
  }

  backend "s3" {
    bucket  = "s3-cloudfix-tfstate-ecs"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    # terraform state locks
    #dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}
