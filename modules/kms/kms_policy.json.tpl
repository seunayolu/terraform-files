{
  "Version": "2012-10-17",
  "Id": "KMS Policy",
  "Statement": [
    {
      "Sid": "Allow administration of the key",
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::${account_id}:root" },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow S3 use of the key",
      "Effect": "Allow",
      "Principal": { "Service": "s3.amazonaws.com" },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    }
  ]
}