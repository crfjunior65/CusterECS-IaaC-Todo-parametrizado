output "vpc_id" {
  value = module.networking.vpc_id
}

output "azs_avaliable" {
  value = data.aws_availability_zones.available.names
}

# ECS Outputs
output "ecs_cluster_id" {
  description = "ID do cluster ECS"
  value       = module.ecs.ecs_cluster_id
}

output "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  value       = module.ecs.ecs_cluster_name
}

output "alb_dns_name" {
  description = "DNS name do Application Load Balancer"
  value       = module.ecs.alb_dns_name
}

output "alb_url" {
  description = "URL completa da aplicação"
  value       = "http://${module.ecs.alb_dns_name}"
}

output "cloudwatch_log_group_name" {
  description = "Nome do CloudWatch Log Group"
  value       = module.ecs.cloudwatch_log_group_name
}

output "ecs_service_name" {
  description = "Nome do serviço ECS"
  value       = module.ecs.ecs_service_name
}

# RDS Outputs
output "db_instance_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "db_instance_id" {
  value = module.rds.db_instance_id
}

output "db_instance_name" {
  value = module.rds.db_instance_name
}

output "db_instance_username" {
  value = module.rds.db_instance_username
}

output "db_instance_password" {
  description = "Senha da instância do banco de dados (marcada como sensível)."
  value       = module.rds.db_instance_password
  sensitive   = true
}

# Valkey Outputs
output "valkey_endpoint" {
  description = "Endpoint primário do Valkey"
  value       = module.valkey.valkey_endpoint
}

output "valkey_port" {
  description = "Porta do Valkey"
  value       = module.valkey.valkey_port
}

output "valkey_reader_endpoint" {
  description = "Endpoint de leitura do Valkey"
  value       = module.valkey.valkey_reader_endpoint
}

# RDS Scheduler Outputs
output "rds_scheduler_lambda_name" {
  description = "Nome da função Lambda RDS Scheduler"
  value       = module.rds_scheduler.lambda_function_name
}

output "rds_scheduler_start_time" {
  description = "Horário de início do RDS (08:00 Brasília)"
  value       = "08:00 Brasília (11:00 UTC) - Segunda a Sexta"
}

output "rds_scheduler_stop_time" {
  description = "Horário de parada do RDS (18:00 Brasília)"
  value       = "18:00 Brasília (21:00 UTC) - Segunda a Sexta"
}

# ECR Output
output "ecr_repository_urls" {
  description = "URLs dos repositórios ECR"
  value       = module.ecr.repository_urls
}
