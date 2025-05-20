output "keypair" {
  description = "EC2 Keypair"
  value       = aws_key_pair.ec2.key_name
}

output "pem_file" {
  description = "Keypair Filename"
  value       = local_file.private_key.filename
}