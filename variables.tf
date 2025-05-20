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

variable "aws_region" {
  description = "REGION"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "default-route" {
  description = "default"
  type        = string
}

variable "portnumber" {
  description = "Security Group Port Number"
  type        = list(string)
}

variable "key_rotation_days" {
  description = "Number of days for key rotation"
  type        = number
}

variable "delete_windows" {
  description = "value for deletion window"
  type        = number
}

variable "my_ip" {
  description = "MY Public IPv4 address"
  type        = string
}