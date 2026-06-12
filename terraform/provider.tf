terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state backend (S3)
  backend "s3" {
    bucket = "devops-terraform-state-bucket"
    key    = "eks/terraform.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "aws-eks-devops"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
