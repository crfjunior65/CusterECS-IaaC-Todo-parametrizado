locals {
  tags = merge(
    var.tags,
    {
      Environment = var.environment
      Projeto     = var.project_name
    }
  )

  cluster_name = var.ecs_cluster_name

  common_tags = {
    Environment = var.environment
    Projeto     = var.project_name
    ManagedBy   = "terraform"
    Owner       = "devops-team"
    Project     = var.ecs_cluster_name
  }

  # Função para calcular subnets baseadas no CIDR da VPC
  # Parse do CIDR base
  cidr_parts       = split(".", split("/", var.vpc_cidr)[0])
  cidr_prefix      = "${local.cidr_parts[0]}.${local.cidr_parts[1]}"
  base_third_octet = tonumber(local.cidr_parts[2])
  cidr_mask        = tonumber(split("/", var.vpc_cidr)[1])

  # Seleciona as AZs baseado no número solicitado
  selected_azs = slice(data.aws_availability_zones.available.names, 0, var.num_azs)

  # Calcula os CIDRs das subnets automaticamente
  public_subnets_cidrs = [for i in range(var.num_azs) :
    "${local.cidr_prefix}.${local.base_third_octet + i}.0/${local.cidr_mask + 8}"
  ]

  ecs_subnets_cidrs = [for i in range(var.num_azs) :
    "${local.cidr_prefix}.${local.base_third_octet + 100 + i}.0/${local.cidr_mask + 8}"
  ]

  rds_subnets_cidrs = [for i in range(var.num_azs) :
    "${local.cidr_prefix}.${local.base_third_octet + 200 + i}.0/${local.cidr_mask + 8}"
  ]

  prefix_project = var.prefix
  environment    = var.environment

}
