resource "aws_subnet" "class-subnet-1" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block[0]
    availability_zone = var.avail_zone[0]
    tags = {
      Name: "${var.env_prefix}-subnet-1"
    }
}

resource "aws_subnet" "class-subnet-2" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block[1]
    availability_zone = var.avail_zone[1]
    tags = {
      Name: "${var.env_prefix}-subnet-2"
    }
}

resource "aws_route_table" "class-route-table" {
  vpc_id = var.vpc_id
  tags = {
    Name: "${var.env_prefix}-rtb"
  }
}

resource "aws_default_route_table" "class-main-rtb" {
  default_route_table_id = var.default_route_table_id
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
  vpc_id = var.vpc_id
  tags = {
    Name: "${var.env_prefix}-igw"
  }
}