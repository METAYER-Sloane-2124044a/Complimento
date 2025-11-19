provider "aws" {
    access_key                  = "test"
    secret_key                  = "test"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true

  endpoints {
    s3         = "http://localhost:4566"
    dynamodb   = "http://localhost:4566"
    lambda     = "http://localhost:4566"
    apigateway = "http://localhost:4566"
  }

  s3_use_path_style = true
}


# S3 bucket
resource "aws_s3_bucket" "complimento_bucket" {
  bucket = "complimento-bucket"
}

# DynamoDB
resource "aws_dynamodb_table" "compliments" {
  name         = "compliments"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "N"
  }
}

resource "null_resource" "insert_compliments" {
  depends_on = [
    aws_dynamodb_table.compliments
  ]

  provisioner "local-exec" {
    command = "py services/dynamodb/insert_compliments.py"
  }
}
