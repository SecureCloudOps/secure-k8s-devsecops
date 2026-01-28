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

variable "tags" {
  type        = map(string)
  description = "Tags to apply to IAM resources."
  default     = {}
}
