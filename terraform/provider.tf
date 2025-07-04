
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.96.0"
    }
  }
  backend "s3" {
    region       = "us-west-1"
    bucket       = "myawspractice2862025"
    key          = "ec2/terrafom.tfstate"
    use_lockfile = false
  }
}

provider "aws" {
  region = var.vpc_region
}