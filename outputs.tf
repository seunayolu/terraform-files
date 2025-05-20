output "instance_ip" {
  description = "Public IP of EC2 Instance"
  value       = module.ec2.public_ip
}

output "pem_file" {
  description = "EC2 Key Pair file"
  value       = module.keypair.pem_file
}