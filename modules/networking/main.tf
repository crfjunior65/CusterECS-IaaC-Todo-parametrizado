resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-vpc_${var.environment}"
    }
  )
}

resource "aws_subnet" "public" {
  count                   = length(var.subnets_public)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnets_public[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name                     = "${var.prefix}-subnet-public-${element(["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"], count.index)}-${var.environment}"
      "kubernetes.io/role/elb" = "1"
    }
  )
}

resource "aws_subnet" "ecs_private" {
  count             = length(var.ecs_private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.ecs_private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name                              = "${var.prefix}-ecs-private-subnet-${element(["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"], count.index)}-${var.environment}"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

resource "aws_subnet" "rds_private" {
  count             = length(var.rds_private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.rds_private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-rds-private-subnet-${element(["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"], count.index)}-${var.environment}"
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-igw-${var.environment}"
    }
  )
}

# ALTERAÇÃO: Apenas um EIP e um NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-nat-eip-${var.environment}"
    }
  )
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-nat-gw-${var.environment}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-public-rt-${var.environment}"
    }
  )
}

# ALTERAÇÃO: Todas as rotas privadas apontam para o mesmo NAT Gateway
resource "aws_route_table" "ecs_private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-ecs-private-rt-${var.environment}"
    }
  )
}

resource "aws_route_table" "rds_private" {
  #count  = length(var.rds_private_subnets_cloudfix)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      #Name = "rds-private-rt-cloudfix-hml-${element(["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"], count.index)}"
      Name = "${var.prefix}-rds-private-rt-${var.environment}"
    }
  )
}

resource "aws_route_table_association" "public" {
  count          = length(var.subnets_public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "ecs_private" {
  count          = length(var.ecs_private_subnets)
  subnet_id      = aws_subnet.ecs_private[count.index].id
  route_table_id = aws_route_table.ecs_private.id
}

resource "aws_route_table_association" "rds_private" {
  count          = length(var.rds_private_subnets)
  subnet_id      = aws_subnet.rds_private[count.index].id
  route_table_id = aws_route_table.rds_private.id
}

resource "aws_security_group" "lb" {
  name        = "lb-sg"
  description = "Security Group para o Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
