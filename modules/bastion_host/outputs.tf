output "bastion_security_group_id" {
  description = "Security Group ID of the bastion host"
  value       = aws_security_group.bastion_sg.id
}

output "bastion_instance_id" {
  description = "Instance ID of the bastion host"
  value       = aws_instance.bastion_host.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion_host.public_ip
}
