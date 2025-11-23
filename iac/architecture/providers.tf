terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0"
    }
  }
  backend "s3" {
    key = "clockin-artifacts/terraform.tfstate"
  }

}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      owner   = "the-pragmatic-programmer"
      project = "clockin-automation"
    }
  }
}