variable "name" {
  type        = string
  description = "Cluster name."
}

variable "cluster_version" {
  type        = string
  description = "EKS cluster version."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the cluster."
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR used to restrict cluster security group ingress."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the cluster and nodes."
}

variable "node_instance_types" {
  type        = list(string)
  description = "Instance types for the managed node group."
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
