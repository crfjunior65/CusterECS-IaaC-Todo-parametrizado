variable "prefix" {
  description = "Prefix for ECR repository names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to ECR repositories"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name (e.g., dev, prod, hml)"
  type        = string

}
