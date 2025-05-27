output "instance_ip" {
  description = "Public IP of EC2 Instance"
  value       = module.ec2.public_ip
}

output "vpc_id" {
  description = "Network Module VPC ID"
  value       = module.network.vpc_id
}