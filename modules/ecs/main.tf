# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-${var.cluster_name}-${var.environment}"

  dynamic "setting" {
    for_each = var.enable_container_insights ? [1] : []
    content {
      name  = "containerInsights"
      value = "enabled"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.prefix}-${var.cluster_name}-${var.environment}"
  })
}

# ECS Cluster Capacity Providers
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = var.capacity_providers

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = var.default_capacity_provider
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = var.alb_name != "" ? var.alb_name : "${var.prefix}-alb-${var.environment}"
  internal           = var.alb_internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.tags, {
    Name = var.alb_name != "" ? var.alb_name : "${var.prefix}-alb-${var.environment}"
  })
}

# ALB Target Group
resource "aws_lb_target_group" "app" {
  name        = var.target_group_name != "" ? var.target_group_name : "${var.prefix}-tg-${var.environment}"
  port        = var.app_port
  protocol    = var.alb_protocol
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = var.healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = var.alb_protocol
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.unhealthy_threshold
  }

  tags = merge(var.tags, {
    Name = var.target_group_name != "" ? var.target_group_name : "${var.prefix}-tg-${var.environment}"
  })
}

# ALB Listener
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.alb_port
  protocol          = var.alb_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "app" {
  name              = var.log_group_name != "" ? var.log_group_name : "/ecs/${var.prefix}-${var.app_name}-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = var.log_group_name != "" ? var.log_group_name : "${var.prefix}-${var.app_name}-logs-${var.environment}"
  })
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.prefix}-${var.app_name}-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = [var.launch_type]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "${var.prefix}-${var.app_name}"
      image = var.app_image
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = data.aws_region.current.id
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = var.environment_variables
    }
  ])

  tags = merge(var.tags, {
    Name = "${var.prefix}-${var.app_name}-task-${var.environment}"
  })
}

# ECS Service
resource "aws_ecs_service" "app" {
  name            = var.service_name != "" ? var.service_name : "${var.prefix}-${var.app_name}-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type

  network_configuration {
    security_groups  = var.security_group_ids
    subnets          = var.subnet_ids
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "${var.prefix}-${var.app_name}"
    container_port   = var.app_port
  }

  depends_on = [aws_lb_listener.app]

  tags = merge(var.tags, {
    Name = var.service_name != "" ? var.service_name : "${var.prefix}-${var.app_name}-service-${var.environment}"
  })
}

# Data sources
data "aws_region" "current" {}
