resource "aws_security_group" "docker_compose" {
  name        = "${var.project_name}-${var.environment}-dockersg"
  description = "Allow HTTP Inbound Traffic to docker compose container"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "DockerSg-${var.environment}"
    Environment = "${var.environment}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "port80" {
  for_each          = var.portnumber
  security_group_id = aws_security_group.docker_compose.id
  cidr_ipv4         = var.my_ip
  from_port         = each.value
  ip_protocol       = "tcp"
  to_port           = each.value
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.docker_compose.id
  cidr_ipv4         = var.default-route
  ip_protocol       = "-1"
}