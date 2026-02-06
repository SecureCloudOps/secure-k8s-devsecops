locals {
  name = "${var.project_name}-${var.environment}"
}

module "vpc" {
  source = "../../modules/vpc"

  name                 = local.name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "eks" {
  source = "../../modules/eks"

  name                = local.name
  cluster_version     = var.cluster_version
  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = var.vpc_cidr
  private_subnet_ids  = module.vpc.private_subnet_ids
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
}

module "ecr" {
  source = "../../modules/ecr"

  name = var.ecr_repo_name
}

module "runner" {
  source = "../../modules/runner"

  project_name        = var.project_name
  environment         = var.environment
  tags                = var.tags
  subnet_id           = element(module.vpc.private_subnet_ids, 0)
  vpc_id              = module.vpc.vpc_id
  aws_region          = var.aws_region
  github_repo         = "SecureCloudOps/secure-k8s-devsecops"
  github_runner_token = var.github_runner_token
}
