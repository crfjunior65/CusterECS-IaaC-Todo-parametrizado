module "networking" {
  source = "./modules/networking"

  vpc_cidr = var.vpc_cidr

  subnets_public            = local.public_subnets_cidrs
  ecs_private_subnets       = local.ecs_subnets_cidrs
  rds_private_subnets       = local.rds_subnets_cidrs
  prefix                    = local.prefix_project
  bastion_security_group_id = "" # Removido temporariamente
  environment               = local.environment

  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.num_azs)

  tags = var.tags
}

module "ecs" {
  source = "./modules/ecs"

  cluster_name       = var.ecs_cluster_name
  vpc_id             = module.networking.vpc_id
  subnet_ids         = module.networking.ecs_private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids
  security_group_ids = [module.networking.ecs_security_group_id, module.networking.alb_security_group_id]
  prefix             = local.prefix_project
  environment        = local.environment
  tags               = var.tags

  # Application Configuration
  app_name      = var.app_name
  app_image     = var.app_image
  app_port      = var.app_port
  task_cpu      = var.task_cpu
  task_memory   = var.task_memory
  desired_count = var.desired_count

  # ALB Configuration
  alb_internal      = var.alb_internal
  health_check_path = var.health_check_path

  # CloudWatch Configuration
  log_retention_days = var.log_retention_days

  # ECS Configuration
  enable_container_insights = var.enable_container_insights
  assign_public_ip          = var.assign_public_ip

  # Environment Variables for Database Connection
  environment_variables = [
    {
      name  = "DB_HOST"
      value = module.rds.db_instance_endpoint
    },
    {
      name  = "DB_NAME"
      value = var.db_name
    },
    {
      name  = "DB_USER"
      value = var.db_username
    },
    {
      name  = "REDIS_HOST"
      value = module.valkey.valkey_endpoint
    },
    {
      name  = "REDIS_PORT"
      value = tostring(module.valkey.valkey_port)
    }
  ]
}

module "rds" {
  source = "./modules/rds"

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  vpc_id                        = module.networking.vpc_id
  subnet_ids                    = module.networking.rds_private_subnet_ids
  security_group_ids            = [module.networking.rds_security_group_id]
  ecs_cluster_security_group_id = module.networking.ecs_security_group_id
  prefix                        = local.prefix_project
  environment                   = local.environment

  instance_class          = var.rds_instance_class
  allocated_storage       = var.rds_storage
  max_allocated_storage   = 100
  backup_retention_period = 7
  skip_final_snapshot     = true

  tags = var.tags
}

module "valkey" {
  source = "./modules/valkey"

  prefix                = local.prefix_project
  project_name          = var.project_name
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.rds_private_subnet_ids
  ecs_security_group_id = module.networking.ecs_security_group_id
  environment           = local.environment

  node_type       = var.valkey_node_type
  num_cache_nodes = var.valkey_num_nodes
  engine_version  = var.valkey_engine_version

  tags = var.tags
}

module "rds_scheduler" {
  source = "./modules/rds-scheduler"

  prefix                 = local.prefix_project
  project_name           = var.project_name
  db_instance_identifier = module.rds.db_instance_id
  aws_region             = var.region
  environment            = local.environment

  tags = var.tags
}

# Bastion e schedulers removidos temporariamente
# module "bastion_scheduler" {
#   source = "./modules/bastion-scheduler"
#
#   prefix              = local.prefix_project
#   project_name        = var.project_name
#   bastion_instance_id = module.bastion_host.bastion_instance_id
#   aws_region          = var.region
#   environment         = local.environment
#
#   tags = var.tags
# }

# module "bastion_host" {
#   source                = "./modules/bastion_host"
#   prefix                = local.prefix_project
#   project_name          = var.project_name
#   bastion_instance_type = var.bastion_instance_type
#   key_name              = var.key_name
#   tags                  = var.tags
#   environment           = local.environment
#   aws_eip_public_ip     = var.aws_eip_public_ip
#
#   vpc_id                = module.networking.vpc_id
#   public_subnet_id      = module.networking.public_subnet_ids[0]
#   rds_security_group_id = module.networking.rds_security_group_id
# }

module "ecr" {
  source = "./modules/ecr"

  prefix      = local.prefix_project
  environment = local.environment

  tags = var.tags
}

# Monitoring será adicionado após correção completa
# module "monitoring" {
#   source = "./modules/monitoring"
#
#   prefix                   = local.prefix_project
#   project_name             = var.project_name
#   environment              = local.environment
#   ecs_cluster_name         = module.ecs.ecs_cluster_name
#   ecs_service_name         = module.ecs.ecs_service_name
#   alb_arn                  = module.ecs.alb_arn
#   target_group_arn         = module.ecs.target_group_arn
#   monitoring_sns_topic_arn = var.monitoring_sns_topic_arn
#
#   tags = var.tags
# }
