variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where EC2 will be launched"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs for EC2"
  type        = list(string)
}

variable "instance-profile" {
  description = "EC2 IAM Instance Profile"
  type        = string
}

variable "keyname" {
  description = "EC2 Keypair"
}
