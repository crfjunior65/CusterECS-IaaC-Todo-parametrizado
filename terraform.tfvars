# Configurações AWS
aws_profile = "CloudFix" # Usado apenas localmente
region      = "us-east-1"

# ECS Configuration
ecs_cluster_name = "cluster"
app_name         = "app"
app_image        = "nginx:latest"
app_port         = 80
task_cpu         = "256"
task_memory      = "512"
desired_count    = 2

# ECS Advanced Configuration
alb_internal              = false
health_check_path         = "/"
log_retention_days        = 14
enable_container_insights = true
assign_public_ip          = false

# Network Configuration
vpc_cidr = "10.0.0.0/16"
num_azs  = 2

# RDS Configuration
rds_instance_class = "db.t3.micro"
rds_storage        = 50
db_name            = "cloudfix"
db_username        = "cloudfix"
db_password        = "cloudfix_password"

# Monitoring Configuration
monitoring_sns_topic_arn = ""
monitored_services = [
  {
    name          = "app"
    namespace     = "default"
    min_pod_count = 2
    cpu_threshold = 80
    mem_threshold = 80
  }
]

# Tags Configuration
tags = {
  Environment = "homologation"
  Projeto     = "cloudfix"
  ManagedBy   = "terraform"
  Owner       = "devops-team"
}

# Deploy de teste (nginx) - Em produção: false
deploy_test_app = true

# Valkey Configuration
valkey_engine_version = "8.0"
valkey_num_nodes      = 1

# Project Configuration
project_name = "plataforma-bet"
prefix       = "cloudfix"
environment  = "hml"
#aws_profile  = "CloudFix" ### "default"

# Bastion Configuration - Comentado para criar novo EIP
# aws_eip_public_ip = "3.220.103.33"
