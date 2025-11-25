# API Gateway Configuration
resource "aws_api_gateway_rest_api" "lambda" {
  name = "lambda_api"
}

# API Gateway Resource for Compliment
resource "aws_api_gateway_resource" "compliment" {
  rest_api_id = aws_api_gateway_rest_api.lambda.id
  parent_id   = aws_api_gateway_rest_api.lambda.root_resource_id
  path_part   = "compliment"
}

# 
resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.lambda.id
  resource_id   = aws_api_gateway_resource.compliment.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway Integration with Lambda
resource "aws_api_gateway_integration" "lambda_get" {
  rest_api_id             = aws_api_gateway_rest_api.lambda.id
  resource_id             = aws_api_gateway_resource.compliment.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${aws_lambda_function.get_lambda_function.arn}/invocations"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_get
  ]
  rest_api_id = aws_api_gateway_rest_api.lambda.id
}

# API Gateway Stage for Development
resource "aws_api_gateway_stage" "dev" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.lambda.id
  deployment_id = aws_api_gateway_deployment.deployment.id

  depends_on = [
    aws_api_gateway_deployment.deployment
  ]

  lifecycle {
    create_before_destroy = true
  }
}