output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_id" {
  description = "IDs of NAT Gateways"
  value       = aws_nat_gateway.main.id
}

output "eip" {
  description = "Elastic IP for Nat Gateway"
  value       = aws_eip.nat.id
}