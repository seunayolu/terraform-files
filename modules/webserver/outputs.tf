output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}

output "ec2_instance_public_ip" {
  value = aws_instance.class-ec2-server.public_ip
}