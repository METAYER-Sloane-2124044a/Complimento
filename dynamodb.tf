# DynamoDB Table for Compliments
resource "aws_dynamodb_table" "compliments" {
  name         = "compliments"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "N"
  }
}

# Insert initial compliments into DynamoDB
resource "null_resource" "insert_compliments" {
  depends_on = [
    aws_dynamodb_table.compliments
  ]

  provisioner "local-exec" {
    environment = merge(
      local.shared_env,
      {
        ENDPOINT_URL = "${var.ENDPOINT_URL}"
      }
    )
    command = "python services/dynamodb/insert_compliments.py"
  }
}