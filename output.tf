output "nom_complet_du_bucket" {
  description = "Le nom du bucket qui a été créé."
  value       = aws_s3_bucket.complimento_bucket.bucket
}