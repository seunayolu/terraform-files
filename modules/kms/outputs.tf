output "key_id" {
  value = aws_kms_key.s3.id
}

output "key_arn" {
  value = aws_kms_key.s3.arn
}