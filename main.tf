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
}

resource "aws_security_group" "class-sg" {
  name        = "class-sg"
  description = "Allow SSH and HTTP Traffic on Port 8080"
  vpc_id      = aws_vpc.class-vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]
    ipv6_cidr_blocks = []
    prefix_list_ids = []

  }

  ingress {
    description      = "HTTP on Port 8080"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = [var.default-route]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.default-route]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"
    values = ["al2023-ami-2023.*-6.1-x86_64"]
  }
}

resource "aws_instance" "class-ec2-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id = module.class-subnet.class-subnet-1.id
  vpc_security_group_ids = [aws_security_group.class-sg.id]
  availability_zone = var.avail_zone[0]

  associate_public_ip_address = true
  key_name = "FREECLASSKEY"

  user_data = file("docker-script.sh")

  user_data_replace_on_change = true
  

  tags = {
    Name: "${var.env_prefix}-ec2-server"
  }
}