output "role_arn" {
  description = "IAM role ARN for GitHub Actions Terraform OIDC."
  value       = aws_iam_role.this.arn
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN."
  value       = aws_iam_openid_connect_provider.github.arn
}
