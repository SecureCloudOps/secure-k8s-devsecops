variable "aws_region" {
  type        = string
  description = "AWS region for bootstrap resources."
  default     = "us-east-1"
  validation {
    condition     = length(var.aws_region) > 0
    error_message = "aws_region must be a non-empty string."
  }
}

variable "state_bucket_name" {
  type        = string
  description = "S3 bucket name for Terraform remote state."
  validation {
    condition     = length(var.state_bucket_name) > 0
    error_message = "state_bucket_name must be a non-empty string."
  }
}

variable "lock_table_name" {
  type        = string
  description = "DynamoDB table name for Terraform state locking."
  validation {
    condition     = length(var.lock_table_name) > 0
    error_message = "lock_table_name must be a non-empty string."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to bootstrap resources."
  default     = {}
}
