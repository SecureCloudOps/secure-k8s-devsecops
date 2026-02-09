output "runner_instance_id" {
  description = "EC2 instance ID for the GitHub Actions runner."
  value       = aws_instance.runner.id
}

output "runner_private_ip" {
  description = "Private IP of the runner instance."
  value       = aws_instance.runner.private_ip
}

output "runner_security_group_id" {
  description = "Security group ID for the runner instance."
  value       = aws_security_group.runner.id
}
