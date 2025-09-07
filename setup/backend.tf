terraform {
  backend "s3" {
    bucket            = "tf-state-dual-tier-app"
    key               = "backend/dualTierApp/terraform.tfstate"
    region            = "us-east-1"
    dynamodb_endpoint = "terraform-state-lock1"
    encrypt           = true

  }
}