# ---- API Gateway ----

# API Gateway Configuration
resource "aws_api_gateway_rest_api" "lambda" {
  name = "lambda_api"
}

# API Gateway Resource for Compliment
# For get method
resource "aws_api_gateway_resource" "compliment" {
  rest_api_id = aws_api_gateway_rest_api.lambda.id
  parent_id   = aws_api_gateway_rest_api.lambda.root_resource_id
  path_part   = "compliment"
}

# For delete method with ID parameter
resource "aws_api_gateway_resource" "compliment_id" {
  rest_api_id = aws_api_gateway_rest_api.lambda.id
  parent_id   = aws_api_gateway_resource.compliment.id
  path_part   = "{id}"
}
# ---- Method and Integration ----

#  API Gateway Method for GET
resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.lambda.id
  resource_id   = aws_api_gateway_resource.compliment.id
  http_method   = "GET"
  authorization = "NONE"
}

# OPTIONS Method for CORS Preflight (GET)
resource "aws_api_gateway_method" "options_delete" {
  rest_api_id   = aws_api_gateway_rest_api.lambda.id
  resource_id   = aws_api_gateway_resource.compliment_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

#  API Gateway Method for DELETE
resource "aws_api_gateway_method" "delete" {
  rest_api_id   = aws_api_gateway_rest_api.lambda.id
  resource_id   = aws_api_gateway_resource.compliment_id.id
  http_method   = "DELETE"
  authorization = "NONE"
}

# ----- API Gateway Integration with Lambda -----
# GET
resource "aws_api_gateway_integration" "lambda_get" {
  rest_api_id             = aws_api_gateway_rest_api.lambda.id
  resource_id             = aws_api_gateway_resource.compliment.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_lambda_function.invoke_arn
}

# DELETE
resource "aws_api_gateway_integration" "lambda_options_delete" {
  rest_api_id             = aws_api_gateway_rest_api.lambda.id
  resource_id             = aws_api_gateway_resource.compliment_id.id
  http_method             = aws_api_gateway_method.options_delete.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_lambda_function.invoke_arn
}

resource "aws_api_gateway_integration" "lambda_delete" {
  rest_api_id             = aws_api_gateway_rest_api.lambda.id
  resource_id             = aws_api_gateway_resource.compliment_id.id
  http_method             = aws_api_gateway_method.delete.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_lambda_function.invoke_arn
}

# ---- Deployment and Stage ----

# API Gateway Deployment
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_get,
    aws_api_gateway_integration.lambda_delete,
    aws_api_gateway_integration.lambda_options_delete
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