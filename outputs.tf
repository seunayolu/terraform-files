output "ec2_instance_public_ip" {
  value = module.class-ec2-server.ec2_instance_public_ip.public_ip
}