# EC2 Instance
resource "aws_instance" "docker_instance" {
  ami           = local.ami_id
  instance_type = var.ec2_instance_type
  key_name      = var.keyname

  iam_instance_profile = var.instance-profile

  ebs_block_device {
    volume_size = 20
    volume_type = gp3
    device_name = "/dev/sda1"
  }

  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true

  user_data = base64encode(local.ec2_userdata_script)

  tags = {
    Name        = "${var.project_name}-ec2"
    Environment = var.environment
  }
}
