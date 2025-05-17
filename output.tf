output "aws_ami_id" {
  value = data.aws_ami.master-class-ami.id
}

output "aws_instance_public_ip" {
  value = aws_instance.master-class-instance.public_ip
}
