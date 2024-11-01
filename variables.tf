variable "lambda_layer" {
  default = "arn:aws:lambda:us-east-2:336392948345:layer:AWSSDKPandas-Python311:17"
} 

variable "step_function_role_name" {
  default = "gutendex-step-function-access"
}

variable "bucket_name" {
  default = "gutendex-bucket"
}

variable "database_name" {
  default = "glue_gutendex_db"
}

variable "crawler_name" {
  default = "gutendex-glue-crawler"
}

variable "lambda_role_name" {
  default = "gutendex-lambda-s3-access"
}

variable "glue_crawler_role_name" {
  default = "gutendex-crawler-s3-glue-access"
}

variable "workgroup_name" {
  default = "gutendex-wg"
}

variable "athena_output_location" {
  default = "s3://gutendex-bucket/athena"
}