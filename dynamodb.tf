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

# DynamoDB Table for Types
resource "aws_dynamodb_table" "types" {
  name         = "types"
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
    aws_dynamodb_table.compliments,
    aws_dynamodb_table.types 
  ]

  triggers = {
    # Compute hash of the data file to re-run if the data compliments changes
    file_hash = filemd5("${path.module}/services/dynamodb/compliments.csv")
    # Compute hash of the data file to re-run if the data types changes
    file_hash = filemd5("${path.module}/services/dynamodb/types.csv")
    # Compute hash of the script to re-run if the script changes
    script_hash = filemd5("${path.module}/services/dynamodb/insert_compliments.py")
  }

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