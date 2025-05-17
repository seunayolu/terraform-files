provider "aws" {
  region = "eu-west-2"
}

# data "aws_availability_zone" "azs" {}

resource "aws_vpc" "master-class-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "master-class-sub-1" {
  vpc_id                  = aws_vpc.master-class-vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, 1)
  availability_zone       = var.azs[0]
  map_public_ip_on_launch = true
  tags = {
    Name : "${var.env_prefix}-sub-1"
  }

}

resource "aws_subnet" "master-class-sub-2" {
  vpc_id                  = aws_vpc.master-class-vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, 2)
  availability_zone       = var.azs[1]
  map_public_ip_on_launch = true
  tags = {
    Name : "${var.env_prefix}-sub-2"
  }
}

resource "aws_route_table" "master-class-rt" {
  vpc_id = aws_vpc.master-class-vpc.id
  tags = {
    Name : "${var.env_prefix}-rtb"
  }
}

resource "aws_default_route_table" "master-class-main-rt" {
  default_route_table_id = aws_vpc.master-class-vpc.default_route_table_id
  tags = {
    Name : "${var.env_prefix}-main-rtb"
  }
}

resource "aws_route_table_association" "class-sub-1-rtb" {
  subnet_id      = aws_subnet.master-class-sub-1.id
  route_table_id = aws_default_route_table.master-class-main-rt.id
}

resource "aws_route_table_association" "class-sub-2-rtb" {
  subnet_id      = aws_subnet.master-class-sub-2.id
  route_table_id = aws_route_table.master-class-rt.id
}

resource "aws_internet_gateway" "master-class-igw" {
  vpc_id = aws_vpc.master-class-vpc.id
  tags = {
    Name : "${var.env_prefix}-igw"
  }
}

resource "aws_eip" "eip-nat-gw" {
  depends_on = [aws_internet_gateway.master-class-igw]
  tags = {
    Name : "${var.env_prefix}-nat-eip"
  }
}

resource "aws_nat_gateway" "master-class-nat-gw" {
  allocation_id = aws_eip.eip-nat-gw.id
  subnet_id     = aws_subnet.master-class-sub-2.id

  depends_on = [aws_internet_gateway.master-class-igw]

  tags = {
    Name : "${var.env_prefix}-nat-igw"
  }
}

resource "aws_route" "master-class-main-nat-gw" {
  route_table_id         = aws_default_route_table.master-class-main-rt.id
  destination_cidr_block = var.default-route
  nat_gateway_id         = aws_nat_gateway.master-class-nat-gw.id
}

resource "aws_route" "master-class-custom-igw" {
  route_table_id         = aws_route_table.master-class-rt.id
  destination_cidr_block = var.default-route
  gateway_id             = aws_internet_gateway.master-class-igw.id
}

resource "aws_security_group" "master-class-sg" {
  name        = "${var.env_prefix}-sg"
  description = "Allow SSH and HTTP Traffic"
  vpc_id      = aws_vpc.master-class-vpc.id

  tags = {
    Name : "${var.env_prefix}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.master-class-sg.id
  cidr_ipv4         = var.my_ip
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.master-class-sg.id
  cidr_ipv4         = var.default-route
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.master-class-sg.id
  cidr_ipv4         = var.default-route
  ip_protocol       = "-1" # semantically equivalent to all ports
}

data "aws_ami" "master-class-ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*.*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "master-class-instance" {
  ami           = data.aws_ami.master-class-ami.id
  instance_type = var.instance_type[0]

  subnet_id              = aws_subnet.master-class-sub-2.id
  vpc_security_group_ids = [aws_security_group.master-class-sg.id]
  availability_zone      = var.azs[1]

  associate_public_ip_address = true

  user_data = file("UserData.sh")

  tags = {
    Name : "${var.env_prefix}-instance"
  }
}