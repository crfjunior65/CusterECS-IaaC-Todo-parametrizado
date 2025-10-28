variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID"
  type        = string
}

variable "rds_security_group_id" {
  description = "RDS security group ID"
  type        = string
}

variable "dev_public_keys" {
  description = "Lista de chaves públicas SSH dos desenvolvedores"
  type        = list(string)
  default     = []
}

variable "aws_eip_public_ip" {
  description = "Public IP of the existing Elastic IP to associate with the bastion host"
  type        = string
}
