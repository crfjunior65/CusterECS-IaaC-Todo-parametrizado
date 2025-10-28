variable "vpc_cidr" {
  description = "CIDR block para a VPC"
  type        = string
}

variable "subnets_public" {
  description = "CIDR blocks para as subnets públicas"
  type        = list(string)
}

variable "ecs_private_subnets" {
  description = "CIDR blocks para as subnets privadas do ECS"
  type        = list(string)
}

variable "rds_private_subnets" {
  description = "CIDR blocks para as subnets privadas do RDS"
  type        = list(string)
}

variable "availability_zones" {
  description = "Zonas de disponibilidade para as subnets"
  type        = list(string)
}

variable "tags" {
  description = "Tags padrão para todos os recursos"
  type        = map(string)
}

variable "prefix" {
  description = "Prefix to project name"
  type        = string
  #default     = "cloudfix"
}

variable "bastion_security_group_id" {
  description = "ID do Security Group do Bastion Host"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (e.g., dev, prod, hml)"
  type        = string

}
