variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "assume_role" {
  default     = "assume_role.json"
  description = "assume role for ec2"
}

variable "iam_permission" {
  default     = "iam_permission.json"
  description = "iam role permission for ec2"
}


