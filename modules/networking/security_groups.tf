# Security Group para ECS
resource "aws_security_group" "ecs" {
  name        = format("%s-ecs-sg", var.prefix)
  description = "Security group para o cluster ECS"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = format("%s-ecs-sg-%s", var.prefix, var.environment)
    }
  )
}

# Regras de entrada para ECS
resource "aws_security_group_rule" "ecs_ingress_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ecs.id
  description              = "Permite trafego HTTP do ALB para ECS"
}

resource "aws_security_group_rule" "ecs_ingress_internal" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.ecs.id
  description       = "Permite trafego interno entre tasks ECS"
}

# Regras de saída para ECS
resource "aws_security_group_rule" "ecs_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs.id
  description       = "Permite todo o trafego de saida do ECS"
}

# Security Group para ALB
resource "aws_security_group" "alb" {
  name        = format("%s-alb-sg", var.prefix)
  description = "Security group para o Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = format("%s-alb-sg-%s", var.prefix, var.environment)
    }
  )
}

# Regras de entrada para ALB
resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Permite trafego HTTP publico para ALB"
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Permite trafego HTTPS publico para ALB"
}

# Regras de saída para ALB
resource "aws_security_group_rule" "alb_egress_ecs" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs.id
  security_group_id        = aws_security_group.alb.id
  description              = "Permite trafego do ALB para ECS"
}

# Security Group para o RDS
resource "aws_security_group" "rds" {
  name        = "rds-sg-cloudfix-hml"
  description = "Security group para o RDS"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "rds-sg-cloudfix-hml"
    }
  )
}

# Regras de entrada para o RDS (ECS)
resource "aws_security_group_rule" "rds_ingress_postgres_ecs" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.ecs.id
  description              = "Permite acesso PostgreSQL do ECS"
}

# Regras de saída para o RDS
resource "aws_security_group_rule" "rds_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds.id
  description       = "Permite todo o trafego de saida do RDS"
}

# Regra para permitir acesso do Bastion Host ao RDS (condicional)
resource "aws_security_group_rule" "rds_ingress_bastion" {
  count                    = var.bastion_security_group_id != "" ? 1 : 0
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = var.bastion_security_group_id
  description              = "Permite acesso PostgreSQL do Bastion Host"
}
