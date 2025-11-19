import csv
import boto3

# Connexion à LocalStack
dynamodb = boto3.resource(
    "dynamodb",
    endpoint_url="http://localhost:4566",
    region_name="us-east-1",
    aws_access_key_id="test",
    aws_secret_access_key="test"
)

table = dynamodb.Table("compliments")

with open("compliments.csv", encoding="utf-8") as f:
    reader = csv.DictReader(f)

    for row in reader:
        # conversion du id en nombre
        item = {
            "id": int(row["id"]),
            "type": row["type"],
            "message": row["message"],
            "image": row["image"]
        }

        table.put_item(Item=item)

        print(f"Inserted: {item}")
        
print("All compliments have been inserted.")