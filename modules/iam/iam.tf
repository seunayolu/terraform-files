locals {
  assume_role    = var.assume_role
  iam_permission = var.iam_permission
}


resource "aws_iam_role" "ec2_assume_role" {
  name               = "${var.project_name}-ec2-role"
  assume_role_policy = file("${path.module}/${local.assume_role}")
}

resource "aws_iam_policy" "iam_permissions" {
  name        = "${var.project_name}-ec2-permission"
  description = "iam permissions for ec2"
  policy      = file("${path.module}/${local.iam_permission}")
}

resource "aws_iam_role_policy_attachment" "role_policy_association" {
  role       = aws_iam_role.ec2_assume_role.name
  policy_arn = aws_iam_policy.iam_permissions.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project_name}-ec2-instance-profile"
  role = aws_iam_role.ec2_assume_role.name
}