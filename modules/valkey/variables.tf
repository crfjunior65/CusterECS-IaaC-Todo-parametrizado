variable "prefix" {
  description = "Prefix to project name"
  type        = string
}

variable "project_name" {
  description = "Name to project for tagging and identification purposes"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where Valkey will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Valkey"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "ECS cluster security group ID for access"
  type        = string
}

variable "node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "Number of cache nodes"
  type        = number
  #default     = 2
}

variable "engine_version" {
  description = "Valkey engine version"
  type        = string
  #default     = "7.2"
}

variable "tags" {
  description = "Tags padrão para todos os recursos"
  type        = map(string)
  default     = {}
}


variable "environment" {
  description = "Environment name (e.g., dev, prod, hml)"
  type        = string

}
