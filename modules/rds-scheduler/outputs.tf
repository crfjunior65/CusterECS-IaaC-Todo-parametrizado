output "lambda_function_name" {
  description = "Nome da função Lambda RDS Scheduler"
  value       = aws_lambda_function.rds_scheduler.function_name
}

output "lambda_function_arn" {
  description = "ARN da função Lambda RDS Scheduler"
  value       = aws_lambda_function.rds_scheduler.arn
}

output "start_rule_name" {
  description = "Nome da regra EventBridge para iniciar RDS"
  value       = aws_cloudwatch_event_rule.start_rds_rule.name
}

output "stop_rule_name" {
  description = "Nome da regra EventBridge para parar RDS"
  value       = aws_cloudwatch_event_rule.stop_rds_rule.name
}
