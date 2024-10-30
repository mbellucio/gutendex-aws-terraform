variable "lambda_role" {}
variable "lambda_layer" {}
variable "bucket_name" {}
variable "database_name" {}
variable "crawler_name" {}
variable "crawler_role" {}

resource "aws_lambda_function" "gutendex-lambda" {
  filename      = "lambda_function.zip"
  function_name = "gutendex-lambda"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  role          = var.lambda_role

  timeout = 900

  layers = [var.lambda_layer]

  source_code_hash = filebase64sha256("./lambda_function.zip")
} 

resource "aws_glue_crawler" "example_crawler" {
  database_name = var.database_name
  name          = var.crawler_name
  role          = var.crawler_role

  s3_target {
    path = "s3://${var.bucket_name}/data"
  }

  configuration = jsonencode({
    Version = 1.0
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
  })

  table_prefix = "gutendex-"
}
