variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

resource "aws_s3_bucket" "storage" {
  bucket = var.bucket_name
  tags   = {
    Name        = var.bucket_name
    Environment = "production"
  }

  force_destroy = true
}