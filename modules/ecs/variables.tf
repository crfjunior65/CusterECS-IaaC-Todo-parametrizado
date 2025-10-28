variable "cluster_name" {
  description = "Nome do cluster ECS"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "subnet_ids" {
  description = "IDs das subnets privadas para ECS"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "IDs das subnets públicas para ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "IDs dos security groups"
  type        = list(string)
}

variable "prefix" {
  description = "Prefixo para recursos"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, hml, prod)"
  type        = string
}

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default     = {}
}

# ECS Task Configuration
variable "app_name" {
  description = "Nome da aplicação"
  type        = string
  default     = "app"
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
  description = "Número desejado de tasks"
  type        = number
  default     = 2
}

variable "environment_variables" {
  description = "Variáveis de ambiente para container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# ALB Configuration
variable "alb_name" {
  description = "Nome do Application Load Balancer"
  type        = string
  default     = ""
}

variable "alb_internal" {
  description = "Se o ALB deve ser interno"
  type        = bool
  default     = false
}

variable "alb_port" {
  description = "Porta do ALB"
  type        = number
  default     = 80
}

variable "alb_protocol" {
  description = "Protocolo do ALB"
  type        = string
  default     = "HTTP"
}

variable "target_group_name" {
  description = "Nome do Target Group"
  type        = string
  default     = ""
}

variable "health_check_path" {
  description = "Caminho para health check"
  type        = string
  default     = "/"
}

variable "health_check_matcher" {
  description = "Códigos HTTP válidos para health check"
  type        = string
  default     = "200"
}

variable "health_check_interval" {
  description = "Intervalo do health check em segundos"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Timeout do health check em segundos"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Número de health checks sucessivos para considerar healthy"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Número de health checks falhados para considerar unhealthy"
  type        = number
  default     = 2
}

# CloudWatch Configuration
variable "log_group_name" {
  description = "Nome do CloudWatch Log Group"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "Dias de retenção dos logs"
  type        = number
  default     = 14
}

# Service Configuration
variable "service_name" {
  description = "Nome do ECS Service"
  type        = string
  default     = ""
}

variable "launch_type" {
  description = "Tipo de launch (FARGATE ou EC2)"
  type        = string
  default     = "FARGATE"
}

variable "assign_public_ip" {
  description = "Atribuir IP público às tasks"
  type        = bool
  default     = false
}

variable "enable_container_insights" {
  description = "Habilitar Container Insights"
  type        = bool
  default     = true
}

variable "capacity_providers" {
  description = "Lista de capacity providers"
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "default_capacity_provider" {
  description = "Capacity provider padrão"
  type        = string
  default     = "FARGATE"
}
