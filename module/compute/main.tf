variable "lambda_role" {}
variable "lambda_layer" {}
variable "bucket_name" {}
variable "database_name" {}
variable "crawler_name" {}
variable "crawler_role" {}
variable "step_function_role" {}

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

  table_prefix = "gutendex_"
}

resource "aws_sfn_state_machine" "gutendex_step_function" {
  name     = "gutendex-ste-function"
  role_arn = var.step_function_role

  definition = jsonencode(jsondecode(<<EOF
    {
      "Comment": "A description of my state machine",
      "StartAt": "gutendex-lambda",
      "States": {
        "gutendex-lambda": {
          "Type": "Task",
          "Resource": "arn:aws:states:::lambda:invoke",
          "OutputPath": "$.Payload",
          "Parameters": {
            "FunctionName": "arn:aws:lambda:us-east-2:676206933182:function:gutendex-lambda:$LATEST"
          },
          "Retry": [
            {
              "ErrorEquals": [
                "Lambda.ServiceException",
                "Lambda.AWSLambdaException",
                "Lambda.SdkClientException",
                "Lambda.TooManyRequestsException"
              ],
              "IntervalSeconds": 1,
              "MaxAttempts": 3,
              "BackoffRate": 2
            }
          ],
          "Next": "StartCrawler"
        },
        "StartCrawler": {
          "Type": "Task",
          "Parameters": {
            "Name": "gutendex-glue-crawler"
          },
          "Resource": "arn:aws:states:::aws-sdk:glue:startCrawler",
          "Next": "WaitForCrawler"
        },
        "WaitForCrawler": {
          "Type": "Wait",
          "Seconds": 20,
          "Next": "CheckCrawlerStatus"
        },
        "CheckCrawlerStatus": {
          "Type": "Task",
          "Resource": "arn:aws:states:::aws-sdk:glue:getCrawler",
          "Parameters": {
            "Name": "gutendex"
          },
          "Next": "IsCrawlerComplete?"
        },
        "IsCrawlerComplete?": {
          "Type": "Choice",
          "Choices": [
            {
              "Variable": "$.Crawler.State",
              "StringEquals": "READY",
              "Next": "Parallel"
            }
          ],
          "Default": "WaitForCrawler"
        },
        "Parallel": {
          "Type": "Parallel",
          "End": true,
          "Branches": [
            {
              "StartAt": "booksPerAuthor",
              "States": {
                "booksPerAuthor": {
                  "Type": "Task",
                  "Resource": "arn:aws:states:::athena:startQueryExecution.sync",
                  "Parameters": {
                    "QueryString": "CREATE OR REPLACE VIEW glue_gutendex_db.books_per_author_view AS WITH extracted_authors AS (SELECT author_info.name AS author_name FROM \"glue_gutendex_db\".\"gutendex_data\", UNNEST(authors) AS t (author_info)) SELECT author_name, COUNT(*) AS book_count FROM extracted_authors WHERE author_name IS NOT NULL AND author_name <> '' AND author_name <> 'Various' GROUP BY author_name ORDER BY book_count DESC LIMIT 10;",
                    "WorkGroup": "primary"
                  },
                  "End": true
                }
              }
            },
            {
              "StartAt": "mostPopularSubjects",
              "States": {
                "mostPopularSubjects": {
                  "Type": "Task",
                  "Resource": "arn:aws:states:::athena:startQueryExecution.sync",
                  "Parameters": {
                    "QueryString": "CREATE OR REPLACE VIEW glue_gutendex_db.most_popular_subjects_view AS WITH extracted_subjects AS (SELECT UPPER(regexp_replace(subject, '[^a-zA-Z0-9 ]', '')) AS cleaned_subject FROM \"glue_gutendex_db\".\"gutendex_data\", UNNEST(subjects) AS t (subject)) SELECT cleaned_subject, COUNT(*) AS subject_count FROM extracted_subjects WHERE cleaned_subject IS NOT NULL AND cleaned_subject <> '' GROUP BY cleaned_subject ORDER BY subject_count DESC LIMIT 10;",
                    "WorkGroup": "primary"
                  },
                  "End": true
                }
              }
            },
            {
              "StartAt": "mostDownloadedBooks",
              "States": {
                "mostDownloadedBooks": {
                  "Type": "Task",
                  "Resource": "arn:aws:states:::athena:startQueryExecution.sync",
                  "Parameters": {
                    "QueryString": "CREATE OR REPLACE VIEW glue_gutendex_db.most_downloaded_books_view AS SELECT title, download_count FROM \"glue_gutendex_db\".\"gutendex_data\" ORDER BY download_count DESC LIMIT 10;",
                    "WorkGroup": "primary"
                  },
                  "End": true
                }
              }
            }
          ]
        }
      }
    }
EOF
))
}
