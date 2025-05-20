locals {
  ec2_userdata_script = templatefile("${path.module}/scripts/user_data.sh.tpl", {
  })
}

data "aws_ami" "ubuntu_2404" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-*.*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  ami_id = data.aws_ami.ubuntu_2404.id
}

