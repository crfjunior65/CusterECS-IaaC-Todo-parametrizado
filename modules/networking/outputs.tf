output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = aws_subnet.public[*].id
}

output "ecs_private_subnet_ids" {
  description = "IDs das subnets privadas do ECS"
  value       = aws_subnet.ecs_private[*].id
}

output "rds_private_subnet_ids" {
  description = "IDs das subnets privadas do RDS"
  value       = aws_subnet.rds_private[*].id
}

output "nat_gateway_ip" {
  description = "IP do NAT Gateway"
  value       = aws_nat_gateway.main.public_ip
}



output "ecs_security_group_id" {
  description = "ID do Security Group do ECS"
  value       = aws_security_group.ecs.id
}

output "alb_security_group_id" {
  description = "ID do Security Group do ALB"
  value       = aws_security_group.alb.id
}

output "rds_security_group_id" {
  description = "ID do Security Group do RDS"
  value       = aws_security_group.rds.id
}
