import os
import csv
import boto3

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CSV_PATH = os.path.join(BASE_DIR, "compliments.csv")

print("Using CSV:", CSV_PATH)

dynamodb = boto3.resource(
    "dynamodb",
    endpoint_url="http://localhost:4566",
    region_name="us-east-1",
    aws_access_key_id="test",
    aws_secret_access_key="test"
)

table = dynamodb.Table("compliments")

# Récupérer tous les items
response = table.scan()
items = response.get("Items", [])

print(f"{len(items)} items found. Deleting...")

# Supprimer chaque item
for item in items:
    table.delete_item(
        Key={"id": item["id"]}
    )
    print("Deleted:", item["id"])

print("Table content wiped successfully.")

with open(CSV_PATH, encoding="utf-8-sig") as f:
    reader = csv.DictReader(f, delimiter=';')

    for row in reader:
        item = {
            "id": int(row["id"]),
            "type": row["type"],
            "message": row["message"],
            "image": row["image"]
        }
        table.put_item(Item=item)
        print("Inserted:", item)

print("All compliments have been inserted.")
