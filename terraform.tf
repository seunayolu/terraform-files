terraform {
  required_version = "~> 1.0"
  backend "s3" {
    bucket       = "infrabucket-iacgitops-eu-west-2"
    key          = "eks_local/state.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
    encrypt      = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.3"
    }
  }
}