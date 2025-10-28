variable "prefix" {
  description = "Prefix to project name"
  type        = string
}

variable "project_name" {
  description = "Name to project for tagging and identification purposes"
  type        = string
}

variable "db_instance_identifier" {
  description = "RDS instance identifier to start/stop"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
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
