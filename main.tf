terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.73.0"
    }
  }
}

module "compute" {
  source = "./module/compute"

  lambda_role = var.lambda_role
  lambda_layer = var.lambda_layer
}

module "storage" {
  source = "./module/storage"
  bucket_name = "gutendex-bucket"
}

