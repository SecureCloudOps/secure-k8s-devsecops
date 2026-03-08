# Secure K8s DevSecOps

[![CI](https://github.com/SecureCloudOps/secure-k8s-devsecops/actions/workflows/ci.yml/badge.svg)](https://github.com/SecureCloudOps/secure-k8s-devsecops/actions/workflows/ci.yml)
[![Terraform Infra](https://github.com/SecureCloudOps/secure-k8s-devsecops/actions/workflows/terraform-infra.yml/badge.svg)](https://github.com/SecureCloudOps/secure-k8s-devsecops/actions/workflows/terraform-infra.yml)
[![K8s Deploy](https://github.com/SecureCloudOps/secure-k8s-devsecops/actions/workflows/k8s-deploy.yml/badge.svg)](https://github.com/SecureCloudOps/secure-k8s-devsecops/actions/workflows/k8s-deploy.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-1.6%2B-7B42BC.svg)](https://www.terraform.io/)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB.svg)](https://www.python.org/)
[![AWS](https://img.shields.io/badge/AWS-EKS-FF9900.svg)](https://aws.amazon.com/eks/)

## Author
- Mohamed Mohamed
- mohamed0395@gmail.com

End-to-end, production-minded DevSecOps platform on AWS EKS. This repo demonstrates secure infrastructure provisioning, OIDC‑based CI/CD, container supply chain scanning, and private‑cluster deployment via a self-hosted runner in the VPC.

## Why This Stands Out
- **Real-world constraints**: private EKS endpoint, no static credentials, immutable image tags
- **Security-first pipeline**: OIDC auth, Trivy scanning, policy-as-code guardrails
- **Operational readiness**: infra bootstrap, remote state, destroy safety, drift‑free workflows
- **Hands-on troubleshooting**: built to show how issues were diagnosed and resolved

## Architecture Summary
- VPC with public and private subnets across two AZs
- Private EKS control plane endpoint with managed node groups in private subnets
- ECR for container images with immutable tags and scan-on-push
- Ingress via NGINX and TLS via cert-manager
- TODO: add architecture diagram in `docs/architecture.png`

## What You Can Demo in 5 Minutes
- **Provision**: Run `terraform-infra` workflow (manual `apply`)
- **Build + Scan**: CI builds image, scans with Trivy, pushes immutable SHA tag to ECR
- **Deploy**: `k8s-deploy` workflow runs on the self-hosted runner inside the VPC

## Security Highlights
- OIDC-based GitHub Actions access with no long-lived credentials
- Immutable container tags and image scanning in ECR
- Network policies for default deny and explicit app allow
- Policy-as-code guardrails (Kyverno, Conftest)

## CI/CD Workflows
- **terraform-infra**: manual `plan/apply/destroy` using OIDC and remote state
- **ci**: build → scan → push (SHA tag only, no `latest`)
- **k8s-deploy**: private-cluster deploy via self-hosted runner (`eks-runner`)

## Terraform Operations
- Terraform plan/apply/destroy are manual-only via GitHub Actions workflow_dispatch
- No static AWS keys or secrets stored in the repository

## GitHub Actions Variables
- Set repository variables in GitHub Settings → Secrets and variables → Actions → Variables
- `TF_GITHUB_ROLE_ARN` must be an IAM role ARN (not a policy ARN)
- Provide all required `TF_VAR_*` variables used by the Terraform workflow

## Running Terraform Workflows
- Use the `terraform-infra` workflow and select `plan`, `apply`, or `destroy`
- `destroy` requires the confirm input `DESTROY`
- No static AWS keys are used, and no `terraform.tfvars` is committed

## Tech Stack
- **AWS**: VPC, EKS, ECR, IAM, CloudWatch, S3, DynamoDB
- **IaC**: Terraform 1.6+ with reusable modules and remote state
- **CI/CD**: GitHub Actions + OIDC, self-hosted runner in private subnet
- **Kubernetes**: NGINX Ingress, cert-manager, HPA, network policies
- **Security**: Trivy, Kyverno, Conftest, least‑privilege IAM

## Local Usage
- Copy `terraform/envs/dev/terraform.tfvars.example` to `terraform/envs/dev/terraform.tfvars`
- Run `terraform init` and `terraform plan` from `terraform/envs/dev`
- `terraform/envs/dev/terraform.tfvars` is gitignored

## Repository Structure
- app/                     FastAPI service
- terraform/               Infrastructure as code
- terraform/bootstrap/      Remote state bootstrap (S3 + DynamoDB)
- terraform/envs/           Environment stacks
- terraform/modules/        Reusable Terraform modules
- k8s/                     Kubernetes manifests and policies
- ci/                      CI definitions
- policies/                Policy-as-code rules
- docs/                    Documentation assets
