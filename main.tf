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
    iam        = "http://localhost:4566"
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


resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.complimento_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.complimento_bucket.id
  key          = "index.html"
  content      = file("${path.module}/web/index.html")
  content_type = "text/html"
}


resource "aws_s3_object" "compliments_html" {
  bucket       = aws_s3_bucket.complimento_bucket.id
  key          = "compliments.html"
  content      = file("${path.module}/web/compliments.html")
  content_type = "text/html"
  etag         = filemd5("${path.module}/web/compliments.html")
}

resource "aws_s3_object" "style_css" {
  bucket       = aws_s3_bucket.complimento_bucket.id
  key          = "style.css"
  content      = file("${path.module}/web/assets/style.css")
  content_type = "text/css"
  etag         = filemd5("${path.module}/web/assets/style.css")
}


resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.complimento_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource = [
          "${aws_s3_bucket.complimento_bucket.arn}/*",
        ],
      },
    ],
  })
  depends_on = [aws_s3_bucket_public_access_block.public_access_block]
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.complimento_bucket.id

  block_public_acls       = false
  block_public_policy     = true
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_object" "image_cute" {
  bucket       = aws_s3_bucket.complimento_bucket.id
  key          = "cute.jpg"
  source       = "${path.module}/services/dynamodb/images/cute.jpg"
  content_type = "image/jpeg"
  etag         = filemd5("${path.module}/services/dynamodb/images/cute.jpg")
}

resource "aws_s3_object" "image_motivation" {
  bucket       = aws_s3_bucket.complimento_bucket.id
  key          = "motivation.jpg"
  source       = "${path.module}/services/dynamodb/images/motivation.jpg"
  content_type = "image/jpeg"
  etag         = filemd5("${path.module}/services/dynamodb/images/motivation.jpg")
}

resource "aws_s3_object" "image_romantique" {
  bucket       = aws_s3_bucket.complimento_bucket.id
  key          = "romantique.jpg"
  source       = "${path.module}/services/dynamodb/images/romantique.jpg"
  content_type = "image/jpeg"
  etag         = filemd5("${path.module}/services/dynamodb/images/romantique.jpg")
}

resource "aws_s3_object" "image_drole" {
  bucket       = aws_s3_bucket.complimento_bucket.id
  key          = "drole.jpg"
  source       = "${path.module}/services/dynamodb/images/drole.jpg"
  content_type = "image/jpeg"
  etag         = filemd5("${path.module}/services/dynamodb/images/drole.jpg")
}

# Init Lambda
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "services/lambda/index.py"
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
  handler       = "index.get_handler_compliment"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.7"
}

# Init API Gateway
resource "aws_api_gateway_rest_api" "lambda" {
  name = "lambda_api"
}

# Ressource /compliment
resource "aws_api_gateway_resource" "compliment" {
  rest_api_id = aws_api_gateway_rest_api.lambda.id
  parent_id   = aws_api_gateway_rest_api.lambda.root_resource_id
  path_part   = "compliment"
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.lambda.id
  resource_id   = aws_api_gateway_resource.compliment.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_get" {
  rest_api_id             = aws_api_gateway_rest_api.lambda.id
  resource_id             = aws_api_gateway_resource.compliment.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_lambda_function.invoke_arn
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.lambda.execution_arn}/*/*/compliment"
}

# Stage for API
# Deployment
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_get
  ]
  rest_api_id = aws_api_gateway_rest_api.lambda.id

  triggers = {
    redeploy = timestamp()
  }
}

# Stage dev
resource "aws_api_gateway_stage" "dev" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.lambda.id
  deployment_id = aws_api_gateway_deployment.deployment.id

  lifecycle {
    create_before_destroy = true
  }
}
