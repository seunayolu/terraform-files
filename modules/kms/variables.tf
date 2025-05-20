variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "key_rotation_days" {
  description = "Number of days for key rotation"
  type        = number
}

variable "delete_windows" {
  description = "value for deletion window"
  type        = number
}