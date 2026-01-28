terraform {
  backend "s3" {
    bucket         = "secure-k8s-terraform-state-bucket"
    key            = "envs/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "secure-k8s-terraform-lock-table"
    encrypt        = true
  }
}
