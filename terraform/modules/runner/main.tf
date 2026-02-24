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
  role       = aws_iam_role.runner.name
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

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
  }

  user_data                   = <<-EOF
#!/usr/bin/env bash
set -euo pipefail

log() { echo "[runner-bootstrap] $${1}"; }

log "Updating packages"
dnf -y update

log "Installing dependencies"
dnf -y install --allowerasing \
  amazon-ssm-agent \
  docker \
  git \
  jq \
  tar \
  gzip \
  unzip \
  curl \
  openssl \
  libicu \
  openssl-libs \
  krb5-libs \
  zlib \
  libstdc++ \
  glibc-langpack-en

systemctl enable --now amazon-ssm-agent
systemctl enable --now docker

log "Install kubectl"
curl -fsSL https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl

log "Create actions user and directories"
id actions >/dev/null 2>&1 || useradd -m -s /bin/bash actions
mkdir -p /opt/actions-runner
chown -R actions:actions /opt/actions-runner

log "Write GitHub App private key"
cat > /opt/gh-app.pem <<'PEM'
${var.github_app_private_key_pem}
PEM
chmod 600 /opt/gh-app.pem
chown actions:actions /opt/gh-app.pem

log "Download GitHub runner"
cd /opt/actions-runner
RUNNER_VERSION="2.320.0"
curl -fsSL -o actions-runner-linux-x64.tar.gz "https://github.com/actions/runner/releases/download/v$${RUNNER_VERSION}/actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz"
tar xzf actions-runner-linux-x64.tar.gz
chown -R actions:actions /opt/actions-runner

b64url() {
  openssl base64 -e -A | tr '+/' '-_' | tr -d '='
}

make_jwt() {
  local app_id="$${1}"
  local pem="/opt/gh-app.pem"
  local iat exp header payload unsigned sig

  iat="$$(date +%s)"
  exp="$$(($${iat} + 540))"

  header="$$(printf '{"alg":"RS256","typ":"JWT"}' | b64url)"
  payload="$$(printf '{"iat":%s,"exp":%s,"iss":"%s"}' "$${iat}" "$${exp}" "$${app_id}" | b64url)"
  unsigned="$${header}.$${payload}"

  sig="$$(printf '%s' "$${unsigned}" | openssl dgst -sha256 -sign "$${pem}" | b64url)"
  printf '%s.%s' "$${unsigned}" "$${sig}"
}

log "Create GitHub App JWT"
APP_ID="${var.github_app_id}"
INSTALL_ID="${var.github_app_installation_id}"
JWT="$$(make_jwt "$${APP_ID}")"

log "Get installation access token"
INSTALL_TOKEN="$$(curl -sS -X POST \
  -H "Authorization: Bearer $${JWT}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/app/installations/$${INSTALL_ID}/access_tokens" | jq -r .token)"

if [ -z "$${INSTALL_TOKEN}" ] || [ "$${INSTALL_TOKEN}" = "null" ]; then
  log "ERROR: failed to get installation token"
  exit 1
fi

log "Get runner registration token"
REPO="${var.github_repo}"
REG_TOKEN="$$(curl -fsSL -X POST \
  -H "Authorization: token $${INSTALL_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/$${REPO}/actions/runners/registration-token" | jq -r .token)"

if [ -z "$${REG_TOKEN}" ] || [ "$${REG_TOKEN}" = "null" ]; then
  log "ERROR: failed to get runner registration token"
  exit 1
fi

log "Configure runner"
sudo -u actions ./config.sh --unattended \
  --url "https://github.com/$${REPO}" \
  --token "$${REG_TOKEN}" \
  --name "${var.runner_name}" \
  --labels "self-hosted,eks-runner" \
  --work "_work"

log "Install and start runner service"
./svc.sh install actions
./svc.sh start

log "Done"
EOF
  user_data_replace_on_change = true

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-runner"
    Project     = var.project_name
    Environment = var.environment
  })
}
