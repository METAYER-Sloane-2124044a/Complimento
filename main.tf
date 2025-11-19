provider "aws" {
    access_key                  = "test"
    secret_key                  = "test"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    endpoints {
        s3 = "http://localhost:4566"
        dynamodb    = "http://localhost:4566"
        lambda      = "http://localhost:4566"
        apigateway  = "http://localhost:4566"
        iam     = "http://localhost:4566"
    }
    s3_use_path_style = true
}

resource "aws_s3_bucket" "complimento_bucket" {
    bucket = "complimento-bucket"
}

# Init Lambda
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "services/lambda/index.js"
  output_path = "services/lambda/lambda_function.zip"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "get_lambda_function" {
  filename      = data.archive_file.lambda.output_path
  function_name = "get_random_lambda_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "nodejs18.x"
}