from diagrams import Cluster, Diagram
from diagrams.aws.compute import EC2, ECR, EKS
from diagrams.aws.database import Dynamodb
from diagrams.aws.devtools import Codebuild
from diagrams.aws.network import NATGateway, PrivateSubnet, PublicSubnet, VPC
from diagrams.aws.security import IAM
from diagrams.aws.storage import S3

with Diagram(
    "Secure K8s DevSecOps Architecture",
    show=False,
    direction="LR",
    filename="docs/Architecture/architecture",
):
    oidc = IAM("GitHub OIDC Role")

    with Cluster("GitHub Actions"):
        ci = Codebuild("CI: Build/Scan")
        deploy = Codebuild("Deploy")

    with Cluster("AWS Account"):
        ecr = ECR("ECR secure-api")

        with Cluster("Terraform Bootstrap"):
            s3 = S3("State Bucket")
            ddb = Dynamodb("State Lock")

        with Cluster("VPC"):
            public = PublicSubnet("Public Subnets")
            private = PrivateSubnet("Private Subnets")
            nat = NATGateway("NAT")

            with Cluster("EKS"):
                eks = EKS("secure-k8s-dev")
                ng = EC2("Managed Node Group")

            runner = EC2("Self-hosted Runner")

    ci >> oidc
    deploy >> oidc

    ci >> ecr
    deploy >> eks

    s3 >> ddb
    public >> nat
    nat >> private

    runner >> eks
    eks >> ng
