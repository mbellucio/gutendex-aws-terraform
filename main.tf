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

  lambda_role_arn = module.security.lambda_role_arn
  lambda_layer = var.lambda_layer
  bucket_name = var.bucket_name
  database_name = var.database_name
  crawler_name = var.crawler_name
  crawler_role = var.crawler_role
  step_function_role = var.step_function_role
}

module "storage" {
  source = "./module/storage"

  bucket_name = var.bucket_name
  database_name = var.database_name
}

module "security" {
  source = "./module/security"

  lambda_role_name = var.lambda_role_name
  bucket_name = var.bucket_name
}