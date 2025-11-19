output "nom_complet_du_bucket" {
  description = "Le nom du bucket qui a été créé."
  value       = aws_s3_bucket.complimento_bucket.bucket
}

output "lambda_api_url" {
  value = "http://localhost:4566/restapis/${aws_api_gateway_rest_api.lambda.id}/dev/_user_request_/compliment"
}
