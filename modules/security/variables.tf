variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
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
  type        = set(string)
}

variable "my_ip" {
  description = "MY Public IPv4 address"
  type        = string
}