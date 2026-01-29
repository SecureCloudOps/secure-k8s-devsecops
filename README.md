# Secure K8s DevSecOps

Production-grade, security-first Kubernetes platform on AWS EKS with Terraform, policy-as-code, and CI/CD integration.

## Architecture Summary
- VPC with public and private subnets across two AZs
- Private EKS control plane endpoint with managed node groups in private subnets
- ECR for container images with immutable tags and scan-on-push
- Ingress via NGINX and TLS via cert-manager

## Security Highlights
- OIDC-based GitHub Actions access with no long-lived credentials
- Immutable container tags and image scanning in ECR
- Network policies for default deny and explicit app allow
- Policy-as-code guardrails (Kyverno, Conftest)

## Terraform Operations
- Terraform plan/apply/destroy are manual-only via GitHub Actions workflow_dispatch
- No static AWS keys or secrets stored in the repository

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
