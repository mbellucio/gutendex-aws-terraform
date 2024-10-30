variable "lambda_role" {
  default = "arn:aws:iam::676206933182:role/service-role/gutendex-role-eqe9wn7d"
}

variable "lambda_layer" {
  default = "arn:aws:lambda:us-east-2:336392948345:layer:AWSSDKPandas-Python311:17"
} 

variable "crawler_role" {
  default = "arn:aws:iam::676206933182:role/AWSGlueAccess"
}

variable "bucket_name" {
  default = "gutendex-bucket"
}

variable "database_name" {
  default = "glue-gutendex-db"
}

variable "crawler_name" {
  default = "gutendex-glue-crawler"
}