# Archive the Lambda function code
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "services/lambda/index.py"
  output_path = "services/lambda/lambda_function.zip"
}

# ---- IAM Role and Policy ----

# IAM Policy Document for Lambda Assume Role
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

# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Permission to Lambda to access DynamoDB
resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}


# ---- Lambda Function ----

# AWS Lambda Function to get random compliment
resource "aws_lambda_function" "get_lambda_function" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "get_random_lambda_function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.get_handler_compliment"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  timeout          = 10
  runtime          = "python3.9"

  environment {
    variables = merge(
      local.shared_env,
      {
        ENDPOINT_URL_LAMBDA = "${var.ENDPOINT_URL_LAMBDA}"
      }
    )
  }
}

# ---- API Gateway ----

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.lambda.execution_arn}/*/*/compliment"
}