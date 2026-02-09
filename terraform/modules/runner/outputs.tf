output "instance_id" {
  description = "EC2 instance ID for the GitHub Actions runner."
  value       = aws_instance.runner.id
}

output "private_ip" {
  description = "Private IP of the runner instance."
  value       = aws_instance.runner.private_ip
}

output "security_group_id" {
  description = "Security group ID for the runner instance."
  value       = aws_security_group.runner.id
}
