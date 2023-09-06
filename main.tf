provider "aws" {
    region = "eu-west-2"
}

variable "cidr_block" {
  description = "cidr blocks for vpc & subnets"
  type = list(string)
}

resource "aws_vpc" "development-vpc" {
    cidr_block = var.cidr_block[2]
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      Name: "development-vpc"
    }

}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.development-vpc.id
    cidr_block = var.cidr_block[0]
    availability_zone = "eu-west-2a"
    tags = {
      Name: "dev-subnet-1"
    }
  
}

data "aws_vpc" "existing" {
    filter {
      name = "tag:Name"
      values = ["project-vpc"]
    }
}

resource "aws_subnet" "dev-subnet-2" {
    vpc_id = data.aws_vpc.existing.id
    cidr_block = var.cidr_block[1]
    availability_zone = "eu-west-2b"
    tags = {
      Name: "dev-subnet-2"
    }
  
}

output "development-vpc" {
    value = aws_vpc.development-vpc.id
}

output "subnet-1" {
    value = aws_subnet.dev-subnet-1.id
}

output "subnet-2" {
    value = aws_subnet.dev-subnet-2.id
}