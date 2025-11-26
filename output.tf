output "nom_complet_du_bucket" {
  value       = aws_s3_bucket.complimento_bucket.bucket
  description = "Le nom du bucket qui a été créé."
}

output "page_accueil" {
  value       = "${var.ENDPOINT_URL}/${aws_s3_bucket.complimento_bucket.bucket}/${var.INDEX_PAGE}"
  description = "URL de la page d'accueil"
}

output "localstack_website_url" {
  description = "URL du site S3 hébergé sur LocalStack"
  value       = "http://${aws_s3_bucket.complimento_bucket.bucket}.s3-website.localhost.localstack.cloud:4566"
}