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
  glue_crawler_role_arn = module.security.glue_crawler_role_arn
  step_function_role_arn = module.security.step_function_role_arn
  workgroup_name = var.workgroup_name
  athena_output_location = var.athena_output_location
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
  glue_crawler_role_name = var.glue_crawler_role_name
  crawler_name = var.crawler_name
  database_name = var.database_name
  step_function_role_name = var.step_function_role_name
  lambda_function_arn = module.compute.lambda_function_arn
}

module "eventbridge" {
  source = "./module/eventbridge" 
  
  step_function_arn = module.compute.step_function_arn
}