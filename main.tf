provider "aws" {
    region = "eu-west-2"
}

resource "aws_vpc" "class-vpc" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      Name: "${var.env_prefix}-vpc"
    }
}

module "class-subnet" {
  source = "./modules/subnets"
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.class-vpc.id
  default_route_table_id = aws_vpc.class-vpc.default_route_table_id
  my_ip = var.my_ip
  default-route = var.default-route
}

module "class-ec2-server" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.class-vpc.id
  my_ip = var.my_ip
  env_prefix = var.env_prefix
  image_name = var.image_name
  instance_type = var.instance_type
  avail_zone = var.avail_zone
  default-route = var.default-route
  subnet_id = module.class-subnet.class-subnet-1.id
}