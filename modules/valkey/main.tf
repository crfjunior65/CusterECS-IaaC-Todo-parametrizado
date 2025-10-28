# Subnet Group para o Valkey
resource "aws_elasticache_subnet_group" "valkey" {
  name       = "${var.prefix}-${var.project_name}-valkey-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.prefix}-${var.project_name}-valkey-subnet-group"
  })
}

# Security Group para o Valkey
resource "aws_security_group" "valkey" {
  name_prefix = "${var.prefix}-${var.project_name}-valkey-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.prefix}-${var.project_name}-valkey-sg"
  })
}

# ElastiCache Replication Group (Valkey)
resource "aws_elasticache_replication_group" "valkey" {
  replication_group_id = "${var.prefix}-${var.project_name}-valkey"
  description          = "Valkey cluster for ${var.project_name}"

  node_type            = var.node_type
  port                 = 6379
  parameter_group_name = "default.valkey8"

  num_cache_clusters = var.num_cache_nodes

  engine         = "valkey"
  engine_version = var.engine_version

  subnet_group_name  = aws_elasticache_subnet_group.valkey.name
  security_group_ids = [aws_security_group.valkey.id]

  at_rest_encryption_enabled = false
  transit_encryption_enabled = false

  automatic_failover_enabled = var.num_cache_nodes > 1
  multi_az_enabled           = var.num_cache_nodes > 1

  maintenance_window       = "sun:03:00-sun:04:00"
  snapshot_retention_limit = 5
  snapshot_window          = "02:00-03:00"

  apply_immediately = true

  tags = merge(var.tags, {
    Name = "${var.prefix}-${var.project_name}-valkey"
  })
}
