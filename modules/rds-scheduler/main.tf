# Criar ZIP da função Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# IAM Role para a Lambda
resource "aws_iam_role" "rds_scheduler_role" {
  name = "${var.prefix}-${var.project_name}-rds-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.prefix}-${var.project_name}-rds-scheduler-role"
  })
}

# IAM Policy para a Lambda
resource "aws_iam_policy" "rds_scheduler_policy" {
  name = "${var.prefix}-${var.project_name}-rds-scheduler-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:StopDBInstance",
          "rds:StartDBInstance",
          "rds:DescribeDBInstances"
        ]
        Resource = "arn:aws:rds:${var.aws_region}:*:db:${var.db_instance_identifier}"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${var.prefix}-${var.project_name}-rds-scheduler:*"
      }
    ]
  })

  tags = var.tags
}

# Anexar policy ao role
resource "aws_iam_role_policy_attachment" "rds_scheduler_attach" {
  role       = aws_iam_role.rds_scheduler_role.name
  policy_arn = aws_iam_policy.rds_scheduler_policy.arn
}

# Função Lambda
resource "aws_lambda_function" "rds_scheduler" {
  function_name = "${var.prefix}-${var.project_name}-rds-scheduler"
  handler       = "lambda_function.handler"
  runtime       = "python3.12"
  role          = aws_iam_role.rds_scheduler_role.arn

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DB_INSTANCE_IDENTIFIER = var.db_instance_identifier
      PROJECT_NAME           = var.project_name
      ENVIRONMENT            = "homolog"
    }
  }

  timeout     = 60
  memory_size = 128

  tags = merge(var.tags, {
    Name = "${var.prefix}-${var.project_name}-rds-scheduler"
  })
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.rds_scheduler.function_name}"
  retention_in_days = 14

  tags = merge(var.tags, {
    Name = "${var.prefix}-${var.project_name}-rds-scheduler-logs"
  })
}

# EventBridge Rule - INICIAR RDS (08:00 Brasília = 11:00 UTC)
resource "aws_cloudwatch_event_rule" "start_rds_rule" {
  name                = "${var.prefix}-${var.project_name}-start-rds"
  description         = "Inicia RDS PostgreSQL às 08:00 (Brasília) - Segunda a Sexta"
  schedule_expression = "cron(0 11 ? * MON-FRI *)"

  tags = merge(var.tags, {
    Name = "${var.prefix}-${var.project_name}-start-rds"
  })
}

# EventBridge Rule - PARAR RDS (18:00 Brasília = 21:00 UTC)
resource "aws_cloudwatch_event_rule" "stop_rds_rule" {
  name                = "${var.prefix}-${var.project_name}-stop-rds"
  description         = "Para RDS PostgreSQL às 18:00 (Brasília) - Segunda a Sexta"
  schedule_expression = "cron(0 21 ? * MON-FRI *)"

  tags = merge(var.tags, {
    Name = "${var.prefix}-${var.project_name}-stop-rds"
  })
}

# Target para INICIAR RDS
resource "aws_cloudwatch_event_target" "start_rds_target" {
  rule      = aws_cloudwatch_event_rule.start_rds_rule.name
  target_id = "StartRDSTarget"
  arn       = aws_lambda_function.rds_scheduler.arn

  input = jsonencode({
    action = "start"
    source = "eventbridge-scheduler"
    time   = "08:00-brasilia"
  })
}

# Target para PARAR RDS
resource "aws_cloudwatch_event_target" "stop_rds_target" {
  rule      = aws_cloudwatch_event_rule.stop_rds_rule.name
  target_id = "StopRDSTarget"
  arn       = aws_lambda_function.rds_scheduler.arn

  input = jsonencode({
    action = "stop"
    source = "eventbridge-scheduler"
    time   = "18:00-brasilia"
  })
}

# Permissão EventBridge → Lambda (INICIAR)
resource "aws_lambda_permission" "allow_eventbridge_start" {
  statement_id  = "AllowEventBridgeStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_rds_rule.arn
}

# Permissão EventBridge → Lambda (PARAR)
resource "aws_lambda_permission" "allow_eventbridge_stop" {
  statement_id  = "AllowEventBridgeStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_rds_rule.arn
}
