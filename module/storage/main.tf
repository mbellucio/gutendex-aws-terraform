variable "bucket_name" {}
variable "database_name" {}

resource "aws_s3_bucket" "storage" {
  bucket = var.bucket_name
  tags   = {
    Name        = var.bucket_name
    Environment = "production"
  }

  force_destroy = true
}

resource "aws_glue_catalog_database" "gutendex_db" {
  name          = var.database_name
  description   = "Glue database"
  location_uri  = "s3://${var.bucket_name}/database"
}

