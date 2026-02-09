data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "runner" {
  name        = "${var.project_name}-${var.environment}-runner-sg"
  description = "Security group for GitHub Actions runner"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_iam_role" "runner" {
  name = "${var.project_name}-${var.environment}-runner-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "runner" {
  name = "${var.project_name}-${var.environment}-runner-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SSMCore"
        Effect = "Allow"
        Action = [
          "ssm:UpdateInstanceInformation",
          "ssmmessages:*",
          "ec2messages:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "EKSRead"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECRRead"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeRepositories"
        ]
        Resource = "*"
      },
      {
        Sid    = "Logs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "runner" {
  role       = aws_iam_role.runner.name
  policy_arn = aws_iam_policy.runner.arn
}

resource "aws_iam_role_policy_attachment" "runner_ssm_managed" {
  role      = aws_iam_role.runner.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "runner" {
  name = "${var.project_name}-${var.environment}-runner-profile"
  role = aws_iam_role.runner.name

  tags = var.tags
}

resource "aws_instance" "runner" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.runner.id]
  iam_instance_profile        = aws_iam_instance_profile.runner.name
  associate_public_ip_address = false

  user_data                   = <<-EOF
  #!/usr/bin/env bash
  set -euo pipefail

  dnf -y update
  dnf -y install docker git jq curl tar gzip
  systemctl enable --now docker

  if ! command -v aws >/dev/null 2>&1; then
    curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip
    dnf -y install unzip
    unzip -q /tmp/awscliv2.zip -d /tmp
    /tmp/aws/install
  fi

  curl -fsSL https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
  chmod +x /usr/local/bin/kubectl

  useradd -m -s /bin/bash actions
  mkdir -p /opt/actions-runner
  chown actions:actions /opt/actions-runner

  cd /opt/actions-runner
  RUNNER_VERSION="2.320.0"
  curl -fsSL -o actions-runner-linux-x64.tar.gz "https://github.com/actions/runner/releases/download/v$${RUNNER_VERSION}/actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz"
  tar xzf actions-runner-linux-x64.tar.gz
  chown -R actions:actions /opt/actions-runner

  sudo -u actions ./config.sh --unattended \
    --url "https://github.com/${var.github_repo}" \
    --token "${var.github_runner_token}" \
    --name "${var.runner_name}" \
    --labels "self-hosted,eks-runner" \
    --work "_work"

  ./svc.sh install actions
  ./svc.sh start
  EOF
  user_data_replace_on_change = true

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-runner"
    Project     = var.project_name
    Environment = var.environment
  })
}
