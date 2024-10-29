provider "aws" {
  region = "us-east-2"
}

resource "aws_lambda_function" "gutendex-lambda" {
  filename      = "lambda_function.zip"
  function_name = "gutendex-lambda"
  handler       = "lambda_function.handler"
  runtime       = "python3.11"
  role          = "arn:aws:iam::676206933182:role/service-role/gutendex-role-eqe9wn7d"

  layers = ["arn:aws:lambda:us-east-2:336392948345:layer:AWSSDKPandas-Python311:17"]

  source_code_hash = filebase64sha256("lambda_function.zip")
}