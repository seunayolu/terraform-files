output "iam_instance_profile" {
  description = "IAM EC2 Profile"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}