terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.9"
    }
  }
  backend "s3" {
    bucket  = "infrabucket-iacgitops"
    key     = "terramodule/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}