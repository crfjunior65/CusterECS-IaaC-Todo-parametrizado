output "db_instance_id" {
  description = "ID da instância do RDS"
  value       = aws_db_instance.main.identifier
}

output "db_instance_arn" {
  description = "ARN da instância do RDS"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "Endpoint da instância do RDS"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_port" {
  description = "Porta da instância do RDS"
  value       = aws_db_instance.main.port
}

output "db_instance_username" {
  description = "Nome de usuário do banco de dados"
  value       = var.db_username
}

output "db_instance_name" {
  description = "Nome do banco de dados"
  value       = var.db_name
}

output "db_instance_password" {
  description = "Senha do banco de dados"
  value       = var.db_password
  sensitive   = true
}
