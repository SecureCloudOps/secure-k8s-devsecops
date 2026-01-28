variable "name" {
  type        = string
  description = "IAM role name."
}

variable "repo" {
  type        = string
  description = "GitHub repository in OWNER/REPO format."
}

variable "branch" {
  type        = string
  description = "GitHub branch allowed to assume the role."
  default     = "main"
}

variable "ecr_repo_arn" {
  type        = string
  description = "ECR repository ARN allowed for push actions."
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name for describe access."
}

variable "cluster_arn" {
  type        = string
  description = "EKS cluster ARN for describe access."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to IAM resources."
  default     = {}
}
