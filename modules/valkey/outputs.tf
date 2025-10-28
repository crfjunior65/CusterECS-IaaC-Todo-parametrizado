output "valkey_endpoint" {
  description = "Valkey primary endpoint"
  value       = aws_elasticache_replication_group.valkey.primary_endpoint_address
}

output "valkey_port" {
  description = "Valkey port"
  value       = aws_elasticache_replication_group.valkey.port
}

output "valkey_reader_endpoint" {
  description = "Valkey reader endpoint"
  value       = aws_elasticache_replication_group.valkey.reader_endpoint_address
}

output "valkey_security_group_id" {
  description = "Valkey security group ID"
  value       = aws_security_group.valkey.id
}
