output "lambda_function_name" {
  description = "Nome da função Lambda Bastion Scheduler"
  value       = aws_lambda_function.bastion_scheduler.function_name
}

output "lambda_function_arn" {
  description = "ARN da função Lambda Bastion Scheduler"
  value       = aws_lambda_function.bastion_scheduler.arn
}

output "start_rule_name" {
  description = "Nome da regra EventBridge para iniciar Bastion"
  value       = aws_cloudwatch_event_rule.start_bastion_rule.name
}

output "stop_rule_name" {
  description = "Nome da regra EventBridge para parar Bastion"
  value       = aws_cloudwatch_event_rule.stop_bastion_rule.name
}
