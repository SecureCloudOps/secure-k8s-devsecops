variable "project_name" {
  type        = string
  description = "Project name used as a prefix for resources."
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev)."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources."
  default     = {}
}

variable "subnet_id" {
  type        = string
  description = "Private subnet ID for the runner instance."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the runner security group."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the runner."
  default     = "t3.small"
}

variable "runner_name" {
  type        = string
  description = "GitHub Actions runner name."
  default     = "eks-runner"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository in OWNER/REPO format."
}

variable "github_app_id" {
  type        = string
  description = "GitHub App ID."
}

variable "github_app_installation_id" {
  type        = string
  description = "GitHub App Installation ID."
}

variable "github_app_private_key_pem" {
  type        = string
  description = "GitHub App private key PEM."
  sensitive   = true
}

variable "aws_region" {
  type        = string
  description = "AWS region for the runner."
}
