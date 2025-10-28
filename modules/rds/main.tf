# Subnet Group para o RDS
resource "aws_db_subnet_group" "main" {
  name       = "rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "rds-subnet-group"
    }
  )
}

# Instância do RDS
resource "aws_db_instance" "main" {
  # identifier = "postgres-${var.environment}"

  identifier            = "${var.prefix}-postgres-${var.environment}"
  engine                = "postgres"
  engine_version        = "17.4"
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  vpc_security_group_ids = var.security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot

  storage_encrypted = true
  multi_az          = false

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-postgres-${var.environment}"
    }
  )
}
