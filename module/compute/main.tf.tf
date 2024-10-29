variable "lambda_role" {}
variable "lambda_layer" {}

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