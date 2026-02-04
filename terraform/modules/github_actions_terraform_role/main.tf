data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]

  tags = var.tags
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.repo}:ref:refs/heads/${var.branch}"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

# Minimal Terraform permissions for VPC/EKS/ECR/Logs in this repo.
data "aws_iam_policy_document" "terraform" {
  statement {
    sid = "StateBucketList"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.state_bucket_name}"
    ]
  }

  statement {
    sid = "StateBucketObjects"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.state_bucket_name}/envs/dev/*"
    ]
  }

  statement {
    sid = "StateLockTable"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeTable",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.lock_table_name}"
    ]
  }

  statement {
    sid = "EC2VPC"
    actions = [
      "ec2:AllocateAddress",
      "ec2:AssociateRouteTable",
      "ec2:AttachInternetGateway",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateInternetGateway",
      "ec2:CreateNatGateway",
      "ec2:CreateRoute",
      "ec2:CreateRouteTable",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSubnet",
      "ec2:CreateTags",
      "ec2:CreateVpc",
      "ec2:DeleteInternetGateway",
      "ec2:DeleteNatGateway",
      "ec2:DeleteRoute",
      "ec2:DeleteRouteTable",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSubnet",
      "ec2:DeleteTags",
      "ec2:DeleteVpc",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeAddresses",
      "ec2:DescribeAddressesAttribute",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNatGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcs",
      "ec2:DescribeVpcAttribute",
      "ec2:DetachInternetGateway",
      "ec2:DisassociateRouteTable",
      "ec2:ModifySubnetAttribute",
      "ec2:ModifyVpcAttribute",
      "ec2:ReleaseAddress"
    ]
    resources = ["*"]
  }

  statement {
    sid = "EKS"
    actions = [
      "eks:CreateCluster",
      "eks:DeleteCluster",
      "eks:DescribeCluster",
      "eks:UpdateClusterConfig",
      "eks:UpdateClusterVersion",
      "eks:CreateNodegroup",
      "eks:DeleteNodegroup",
      "eks:DescribeNodegroup",
      "eks:UpdateNodegroupConfig",
      "eks:UpdateNodegroupVersion",
      "eks:ListClusters",
      "eks:ListNodegroups",
      "eks:TagResource",
      "eks:UntagResource"
    ]
    resources = ["*"]
  }

  statement {
    sid = "IAM"
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:DetachRolePolicy",
      "iam:GetOpenIDConnectProvider",
      "iam:GetPolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:ListOpenIDConnectProviders",
      "iam:PassRole",
      "iam:TagRole",
      "iam:UntagRole"
    ]
    resources = ["*"]
  }

  statement {
    sid = "ECRRead"
    actions = [
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
      "ecr:ListImages",
      "ecr:BatchGetImage",
      "ecr:ListTagsForResource"
    ]
    resources = ["*"]
  }

  statement {
    sid = "Logs"
    actions = [
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
      "logs:DeleteLogGroup",
      "logs:PutRetentionPolicy",
      "logs:TagResource",
      "logs:UntagResource"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "STSEnsureIdentity"
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "terraform" {
  name   = "${var.name}-policy"
  policy = data.aws_iam_policy_document.terraform.json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "terraform" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.terraform.arn
}
