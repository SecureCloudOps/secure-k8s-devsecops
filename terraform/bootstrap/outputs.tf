output "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state."
  value       = aws_s3_bucket.state.id
}

output "state_lock_table_name" {
  description = "DynamoDB table name for Terraform state locking."
  value       = aws_dynamodb_table.lock.name
}

output "terraform_github_role_arn" {
  description = "IAM role ARN for GitHub Actions Terraform OIDC."
  value       = module.github_actions_terraform_role.role_arn
}
