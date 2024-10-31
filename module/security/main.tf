variable "lambda_role_name" {}
variable "bucket_name" {}
variable "glue_crawler_role_name" {}
variable "database_name" {}

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