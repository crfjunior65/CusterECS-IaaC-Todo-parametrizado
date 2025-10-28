variable "prefix" {
  description = "Prefixo para recursos"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, hml, prod)"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  type        = string
}

variable "ecs_service_name" {
  description = "Nome do serviço ECS"
  type        = string
}

variable "alb_arn" {
  description = "ARN do Application Load Balancer"
  type        = string
}

variable "target_group_arn" {
  description = "ARN do Target Group"
  type        = string
}

variable "monitoring_sns_topic_arn" {
  description = "ARN do tópico SNS para notificações"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default     = {}
}
