variable "region" {
  description = "Region AWS where the Network resources will be deployed, e.g., us-east-1, for the USA North Virginia region"
  type        = string
  default     = "us-east-1"
}

# ECS Configuration (substituindo EKS)
variable "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  type        = string
}

variable "app_image" {
  description = "Imagem Docker da aplicação"
  type        = string
  default     = "nginx:latest"
}

variable "app_port" {
  description = "Porta da aplicação"
  type        = number
  default     = 80
}

variable "task_cpu" {
  description = "CPU para task ECS (256, 512, 1024, 2048, 4096)"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Memória para task ECS (512, 1024, 2048, 4096, 8192)"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Número desejado de tasks ECS"
  type        = number
  default     = 2
}

# ECS Advanced Configuration
variable "app_name" {
  description = "Nome da aplicação ECS"
  type        = string
  default     = "app"
}

variable "alb_internal" {
  description = "Se o ALB deve ser interno"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "Caminho para health check"
  type        = string
  default     = "/"
}

variable "log_retention_days" {
  description = "Dias de retenção dos logs CloudWatch"
  type        = number
  default     = 14
}

variable "enable_container_insights" {
  description = "Habilitar Container Insights"
  type        = bool
  default     = true
}

variable "assign_public_ip" {
  description = "Atribuir IP público às tasks ECS"
  type        = bool
  default     = false
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block para a VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "num_azs" {
  description = "Number of Availability Zones for use (2 or 3)"
  type        = number
  default     = 2
  validation {
    condition     = var.num_azs >= 2 && var.num_azs <= 3
    error_message = "Number of AZs must be 2 or 3."
  }
}

# RDS Configuration
variable "rds_instance_class" {
  description = "Classe da instância RDS"
  type        = string
}

variable "rds_storage" {
  description = "Armazenamento inicial do RDS em GB"
  type        = number
  default     = 50
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "cloudfix-postgres"
}

variable "db_username" {
  description = "Nome de usuário do banco de dados"
  type        = string
  default     = "cloudfix"
}

variable "db_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}

# Valkey Configuration
variable "valkey_engine_version" {
  description = "Valkey engine version"
  type        = string
  default     = "8.0"
}

variable "valkey_num_nodes" {
  description = "Number of Valkey cache nodes"
  type        = number
  default     = 2
}

variable "valkey_node_type" {
  description = "Tipo de instância para o Valkey"
  type        = string
  default     = "cache.t3.micro"
}

# Bastion Configuration
variable "key_name" {
  description = "Nome do par de chaves SSH para acesso às instâncias EC2"
  type        = string
  default     = "aws-key-terraform"
}

variable "bastion_instance_type" {
  description = "Tipo de instância para o Bastion Host"
  type        = string
  default     = "t3.micro"
}

variable "aws_eip_public_ip" {
  description = "Public IP of the existing Elastic IP to associate with the bastion host"
  type        = string
  default     = ""
}

# Monitoring Configuration
variable "monitoring_sns_topic_arn" {
  description = "Opcional: O ARN de um tópico SNS para notificações dos alarmes do CloudWatch."
  type        = string
  default     = ""
}

variable "monitored_services" {
  description = "Uma lista de serviços específicos para criar alarmes detalhados."
  type = list(object({
    name          = string
    namespace     = string
    min_pod_count = number
    cpu_threshold = number
    mem_threshold = number
  }))
  default = [
    {
      name          = "cloudfix-app"
      namespace     = "default"
      min_pod_count = 2
      cpu_threshold = 80
      mem_threshold = 80
    }
  ]
}

variable "deploy_test_app" {
  description = "Deploy aplicação de teste (nginx). Em produção: false"
  type        = bool
  default     = true
}

# Project Configuration
variable "environment" {
  description = "Deployment environment name, such as 'dev', 'hml', 'stag', or 'prod'. his categorizes the Network resources by their usage stage"
  type        = string
}

variable "LABEL" {
  description = "Tipo de agregação para métricas (AVG, MAX, MIN, SUM) CloudWatch Dashboards"
  type        = string
  default     = "AVG"
}

variable "project_name" {
  description = "Name to project for tagging and identification purposes"
  type        = string
}

variable "prefix" {
  description = "Prefix to project name"
  type        = string
}

variable "trusted_users_arns" {
  description = "List of IAM user ARNs that can assume the EKS viewer role (DEPRECATED)"
  type        = list(string)
  default     = []
}

# Tags Configuration
variable "tags" {
  description = "Tags padrão para todos os recursos"
  type        = map(string)
  default = {
    Environment = "homologation"
    Projeto     = "cloudfix"
    ManagedBy   = "terraform"
    Owner       = "devops-team"
  }
}

variable "profile" {
  description = "Profile Account AWS"
  type        = string
}
