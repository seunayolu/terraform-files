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

resource "aws_subnet" "class-subnet-1" {
    vpc_id = aws_vpc.class-vpc.id
    cidr_block = var.subnet_cidr_block[0]
    availability_zone = var.avail_zone[0]
    tags = {
      Name: "${var.env_prefix}-subnet-1"
    }
}

resource "aws_subnet" "class-subnet-2" {
    vpc_id = aws_vpc.class-vpc.id
    cidr_block = var.subnet_cidr_block[1]
    availability_zone = var.avail_zone[1]
    tags = {
      Name: "${var.env_prefix}-subnet-2"
    }
}

resource "aws_route_table" "class-route-table" {
  vpc_id = aws_vpc.class-vpc.id
  tags = {
    Name: "${var.env_prefix}-rtb"
  }
}

resource "aws_default_route_table" "class-main-rtb" {
  default_route_table_id = aws_vpc.class-vpc.default_route_table_id
  tags = {
    Name: "${var.env_prefix}-class-mainrtb"
  }
}

resource "aws_route_table_association" "rtb-subnet-1" {
  subnet_id = aws_subnet.class-subnet-1.id
  route_table_id = aws_route_table.class-route-table.id
}

resource "aws_route_table_association" "rtb-subnet-2" {
  subnet_id = aws_subnet.class-subnet-2.id
  route_table_id = aws_default_route_table.class-main-rtb.id
}

resource "aws_route" "custom-rtb-igw" {
  route_table_id = aws_route_table.class-route-table.id
  destination_cidr_block = var.default-route
  gateway_id = aws_internet_gateway.class-internet-gateway.id
}

resource "aws_route" "default-rtb-igw" {
  route_table_id = aws_default_route_table.class-main-rtb.id
  destination_cidr_block = var.default-route
  gateway_id = aws_internet_gateway.class-internet-gateway.id
}

resource "aws_internet_gateway" "class-internet-gateway" {
  vpc_id = aws_vpc.class-vpc.id
  tags = {
    Name: "${var.env_prefix}-igw"
  }
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

output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
  
}

resource "aws_instance" "class-ec2-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.class-subnet-1.id
  vpc_security_group_ids = [aws_security_group.class-sg.id]
  availability_zone = var.avail_zone[0]

  associate_public_ip_address = true
  key_name = "FREECLASSKEY"

  tags = {
    Name: "${var.env_prefix}-ec2-server"
  }
  
}