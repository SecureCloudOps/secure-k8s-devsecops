variable "aws_region" {
  type        = string
  description = "AWS region for the deployment."
  validation {
    condition     = length(var.aws_region) > 0
    error_message = "aws_region must be a non-empty string."
  }
}

variable "project_name" {
  type        = string
  description = "Project name used as a prefix for resources."
  validation {
    condition     = length(var.project_name) > 0
    error_message = "project_name must be a non-empty string."
  }
}

variable "environment" {
  type        = string
  description = "Environment name, e.g., dev."
  validation {
    condition     = length(var.environment) > 0
    error_message = "environment must be a non-empty string."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDR blocks (one per AZ)."
  validation {
    condition     = length(var.public_subnet_cidrs) > 0
    error_message = "public_subnet_cidrs must not be empty."
  }
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDR blocks (one per AZ)."
  validation {
    condition     = length(var.private_subnet_cidrs) > 0
    error_message = "private_subnet_cidrs must not be empty."
  }
}

variable "azs" {
  type        = list(string)
  description = "List of availability zones to use."
}

variable "cluster_version" {
  type        = string
  description = "EKS Kubernetes version."
  validation {
    condition     = length(var.cluster_version) > 0
    error_message = "cluster_version must be a non-empty string."
  }
}

variable "node_instance_types" {
  type        = list(string)
  description = "Instance types for the managed node group."
  validation {
    condition     = length(var.node_instance_types) > 0
    error_message = "node_instance_types must not be empty."
  }
}

variable "node_desired_size" {
  type        = number
  description = "Desired node group size."
}

variable "node_min_size" {
  type        = number
  description = "Minimum node group size."
}

variable "node_max_size" {
  type        = number
  description = "Maximum node group size."
}

variable "ecr_repo_name" {
  type        = string
  description = "ECR repository name."
  validation {
    condition     = length(var.ecr_repo_name) > 0
    error_message = "ecr_repo_name must be a non-empty string."
  }
}

variable "github_repo" {
  type        = string
  description = "GitHub repository in OWNER/REPO format."
  validation {
    condition     = length(var.github_repo) > 0
    error_message = "github_repo must be a non-empty string."
  }
}

variable "github_branch" {
  type        = string
  description = "GitHub branch allowed to assume the role."
  default     = "main"
}

variable "github_runner_token" {
  type        = string
  description = "GitHub Actions runner registration token."
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources."
  default     = {}
}
