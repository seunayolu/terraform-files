output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.docker_instance.id
}

output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.docker_instance.private_ip
}

output "public_ip" {
  description = "Public IP of the EC2 Instance"
  value       = aws_instance.docker_instance.public_ip
}