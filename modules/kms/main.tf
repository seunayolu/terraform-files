data "aws_caller_identity" "current" {}

data "template_file" "kms_policy" {
  template = file("${path.module}/kms_policy.json.tpl")
  vars = {
    account_id = data.aws_caller_identity.current.account_id
  }
}


resource "aws_kms_key" "s3" {
  description             = "KMS key for S3 encryption"
  deletion_window_in_days = var.delete_windows
  enable_key_rotation     = true
  rotation_period_in_days = var.key_rotation_days

  policy = data.template_file.kms_policy.rendered

  tags = {
    Environment = "${var.project_name}-${var.environment}"
  }
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.project_name}-${var.environment}-s3-key"
  target_key_id = aws_kms_key.s3.id
}

