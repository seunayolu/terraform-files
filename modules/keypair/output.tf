output "keypair" {
  description = "EC2 Keypair"
  value       = aws_key_pair.ec2.key_name
}