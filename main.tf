provider "aws" {
  region = var.aws_region
}

# VPC and Network Module
module "network" {
  source = "./modules/network"

  default-route = var.default-route
  project_name  = var.project_name
  vpc_cidr      = var.vpc_cidr
  environment   = var.environment
}

# Security Groups Module
module "security" {
  source = "./modules/security"

  vpc_id        = module.network.vpc_id
  vpc_cidr      = var.vpc_cidr
  default-route = var.default-route
  project_name  = var.project_name
  environment   = var.environment
  portnumber    = var.portnumber
  my_ip         = var.my_ip

}

module "ec2" {
  source = "./modules/ec2"

  project_name       = var.project_name
  instance-profile   = module.iam.iam_instance_profile
  keyname            = module.keypair.keypair
  environment        = var.environment
  vpc_id             = module.network.vpc_id
  aws_region         = var.aws_region
  subnet_id          = module.network.public_subnet_ids[0]
  security_group_ids = [module.security.docker_compose_sg]
  ec2_instance_type  = var.ec2_instance_type
  depends_on         = [module.s3]
  bucket_name        = module.s3.bucket_name
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
}

module "kms" {
  source            = "./modules/kms"
  environment       = var.environment
  project_name      = var.project_name
  key_rotation_days = var.key_rotation_days
  delete_windows    = var.delete_windows
}

module "s3" {
  source       = "./modules/s3"
  environment  = var.environment
  project_name = var.project_name
  kms_key_arn  = module.kms.key_arn
  kms_key_id   = module.kms.key_id
}

module "keypair" {
  source       = "./modules/keypair"
  environment  = var.environment
  project_name = var.project_name
}