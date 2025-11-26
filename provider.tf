# AWS Provider Configuration
provider "aws" {
  access_key                  = var.AWS_ACCESS_KEY_ID
  secret_key                  = var.AWS_SECRET_ACCESS_KEY
  region                      = var.REGION_NAME
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  endpoints {
    s3         = "${var.ENDPOINT_URL}"
    dynamodb   = "${var.ENDPOINT_URL}"
    lambda     = "${var.ENDPOINT_URL}"
    apigateway = "${var.ENDPOINT_URL}"
    iam        = "${var.ENDPOINT_URL}"
  }
  s3_use_path_style = true
}