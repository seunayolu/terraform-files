resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2" {
  key_name   = "ec2_key"
  public_key = tls_private_key.ec2.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.ec2.private_key_pem
  filename = "${path.module}/ec2_key.pem"
}