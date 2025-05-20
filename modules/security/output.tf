output "docker_compose_sg" {
  description = "ID of EC2 security group"
  value       = aws_security_group.docker_compose.id
}