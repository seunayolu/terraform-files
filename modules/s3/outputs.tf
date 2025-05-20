output "bucket_name" {
  value = aws_s3_bucket.docker_files.id
}

output "bucket_arn" {
  value = aws_s3_bucket.docker_files.arn
}