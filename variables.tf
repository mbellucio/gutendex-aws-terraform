variable "lambda_role" {
  default = "arn:aws:iam::676206933182:role/service-role/gutendex-role-eqe9wn7d"
}

variable "lambda_layer" {
  default = "arn:aws:lambda:us-east-2:336392948345:layer:AWSSDKPandas-Python311:17"
} 

variable "crawler_role" {
  default = "arn:aws:iam::676206933182:role/AWSGlueAccess"
}

variable "step_function_role" {
  default = "arn:aws:iam::676206933182:role/service-role/StepFunctions-MyStateMachine-hqoodi2ss-role-dxb9lhpxn"
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