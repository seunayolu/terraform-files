resource "aws_s3_bucket" "docker_files" {
  bucket        = "${var.project_name}-${var.environment}-classof25bucket"
  force_destroy = true

  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "docker_files" {
  bucket = aws_s3_bucket.docker_files.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_id
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "docker_files" {
  bucket                  = aws_s3_bucket.docker_files.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

locals {
  s3_files = {
    "Dockerfile"  = "${path.module}/Dockerfile"
    "compose.yml" = "${path.module}/compose.yml"
  }
}

resource "aws_s3_object" "docker_files" {
  for_each   = local.s3_files
  bucket     = aws_s3_bucket.docker_files.id
  key        = each.key
  source     = each.value
  kms_key_id = var.kms_key_arn
}