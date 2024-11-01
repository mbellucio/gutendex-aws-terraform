variable "lambda_role_name" {}
variable "bucket_name" {}
variable "glue_crawler_role_name" {}
variable "crawler_name" {}
variable "database_name" {}
variable "step_function_role_name" {}
variable "lambda_function_arn" {}

// =====================================
//                LAMBDA
// =====================================

resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name = "${var.lambda_role_name}-s3-access-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}

// =====================================
//              Glue Crawler
// =====================================

resource "aws_iam_role" "glue_crawler_role" {
  name = var.glue_crawler_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "glue.amazonaws.com",
            "ec2.amazonaws.com"
        ]}
      }
    ]
  })
}

resource "aws_iam_policy" "glue_crawler_s3_access_policy" {
  name = "${var.glue_crawler_role_name}-s3-access-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "glue_crawler_glue_access_policy" {
  name = "${var.glue_crawler_role_name}-glue-access-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "glue:GetDatabase",
          "glue:GetTable",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:DeleteTable"
        ]
        Resource = [
          "arn:aws:glue:*:*:catalog",
          "arn:aws:glue:*:*:database/${var.database_name}",
          "arn:aws:glue:*:*:table/${var.database_name}/*"
        ]
        Effect = "Allow"
      },
      {
        Action = [
          "glue:GetUserDefinedFunctions",
          "glue:GetSecurityConfiguration"
        ]
        Resource = "*"
        Effect    = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "glue_crawler_cloudwatch_logs_policy" {
  name = "${var.glue_crawler_role_name}-cloudwatch-logs-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents"
        ]
        Resource = "*"
        Effect    = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_crawler_s3_access_attach" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = aws_iam_policy.glue_crawler_s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "glue_crawler_glue_access_attach" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = aws_iam_policy.glue_crawler_glue_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "glue_crawler_cloudwatch_logs_attach" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = aws_iam_policy.glue_crawler_cloudwatch_logs_policy.arn
}

output "glue_crawler_role_arn" {
  value = aws_iam_role.glue_crawler_role.arn
}

// =====================================
//             Step Function
// =====================================

resource "aws_iam_role" "step_function_role" {
  name = var.step_function_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "step_function_athena_execution_policy" {
  name = "${var.step_function_role_name}-athena-execution-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:GetQueryResultsStream",
          "athena:CancelQueryExecution",
          "athena:GetWorkGroup",
          "athena:ListNamedQueries",
          "athena:CreateNamedQuery",
          "athena:DeleteNamedQuery"
        ]
        Resource = "*"
        Effect    = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "step_function_lambda_invoke_policy" {
  name        = "${var.step_function_role_name}-lambda-invoke-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction",
          "lambda:GetFunctionConfiguration"
        ]
        Resource = "arn:aws:lambda:*:*:*"
        Effect    = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "step_function_glue_crawler_control_policy" {
  name = "${var.step_function_role_name}-glue-crawler-control-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "glue:StartCrawler",
          "glue:GetCrawler",
          "glue:GetTable",
          "glue:GetDatabase",
          "glue:CreateTable",
          "glue:UpdateTable"
        ]
        Resource = [
          "arn:aws:glue:*:*:catalog",
          "arn:aws:glue:*:*:crawler/${var.crawler_name}",
          "arn:aws:glue:*:*:database/${var.database_name}",
          "arn:aws:glue:*:*:table/${var.database_name}/*"
        ]
        Effect = "Allow"
      },
      {
        Action = [
          "glue:GetUserDefinedFunctions",
          "glue:GetSecurityConfiguration"
        ]
        Resource = "*"
        Effect    = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "athena_output_bucket_policy" {
  name = "athena-output-bucket-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
        Effect = "Allow"
      }
    ]
  })
}

# resource "aws_iam_role_policy_attachment" "lambda_athena_output_attach" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = aws_iam_policy.athena_output_bucket_policy.arn
# }

resource "aws_iam_role_policy_attachment" "step_function_athena_output_attach" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.athena_output_bucket_policy.arn
}

resource "aws_iam_role_policy_attachment" "step_function_lambda_invoke_attach" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_lambda_invoke_policy.arn
}

resource "aws_iam_role_policy_attachment" "step_function_athena_execution_attach" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_athena_execution_policy.arn
}

resource "aws_iam_role_policy_attachment" "step_function_s3_access_attach" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "step_function_glue_crawler_control_attach" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_glue_crawler_control_policy.arn
}

output "step_function_role_arn" {
  value = aws_iam_role.step_function_role.arn
}

