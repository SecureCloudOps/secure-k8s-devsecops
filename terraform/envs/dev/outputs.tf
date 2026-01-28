output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint."
  value       = module.eks.cluster_endpoint
}

output "ecr_repository_url" {
  description = "ECR repository URL."
  value       = module.ecr.repository_url
}

output "terraform_github_role_arn" {
  description = "IAM role ARN for GitHub Actions Terraform OIDC."
  value       = module.github_actions_terraform_role.role_arn
}
