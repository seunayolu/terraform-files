output "ec2_public_ip" {
  value = module.class-ec2-server.instance.public_ip
}