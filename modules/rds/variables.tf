
variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "cloudfix"
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
  default     = "cloudfix_password" # Em produção, usar um secret manager
}

variable "vpc_id" {
  description = "ID da VPC onde o RDS será criado"
  type        = string
}

variable "subnet_ids" {
  description = "IDs das subnets onde o RDS será criado"
  type        = list(string)
}

variable "security_group_ids" {
  description = "IDs dos security groups para o RDS"
  type        = list(string)
}

variable "instance_class" {
  description = "Classe da instância do RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Espaço em disco alocado para o RDS (GB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Espaço máximo em disco que o RDS pode crescer (GB)"
  type        = number
  default     = 100
}

variable "backup_retention_period" {
  description = "Período de retenção dos backups (dias)"
  type        = number
  default     = 0
}

variable "skip_final_snapshot" {
  description = "Pular snapshot final ao destruir o banco"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags comuns para todos os recursos"
  type        = map(string)
  default     = {}
}

variable "ecs_cluster_security_group_id" {
  description = "Security group ID do cluster ECS para permitir acesso ao RDS"
  type        = string
}

variable "prefix" {
  description = "Prefixo do projeto (herdado da raiz)"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (e.g., dev, prod, hml)"
  type        = string

}
