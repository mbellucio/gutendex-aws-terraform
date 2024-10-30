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
  bucket_name = var.bucket_name
  database_name = var.database_name
  crawler_name = var.crawler_name
  crawler_role = var.crawler_role
}

module "storage" {
  source = "./module/storage"
  bucket_name = var.bucket_name
  database_name = var.database_name
}

