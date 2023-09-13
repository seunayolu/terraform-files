resource "aws_security_group" "class-sg" {
  name        = "class-sg"
  description = "Allow SSH and HTTP Traffic on Port 8080"
  vpc_id      = var.vpc_id

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
    values = [var.image_name]
  }
}

resource "aws_instance" "class-ec2-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id = var.subnet_id
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