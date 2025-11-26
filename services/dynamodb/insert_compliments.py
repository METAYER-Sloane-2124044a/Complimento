import os
import csv
import boto3

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CSV_PATH = os.path.join(BASE_DIR, "compliments.csv")

print("Using CSV:", CSV_PATH)

try:
    dynamodb = boto3.resource(
        "dynamodb",
        endpoint_url=os.environ["ENDPOINT_URL"],
        region_name=os.environ["REGION_NAME"],
        aws_access_key_id=os.environ["AWS_ACCESS_KEY_ID"],
        aws_secret_access_key=os.environ["AWS_SECRET_ACCESS_KEY"]
    )
    table = dynamodb.Table("compliments")
    print(f"Connection established : {table.name}")
except KeyError as e:
    print(f"ERROR: Missing environment variable: {e}")
except Exception as e:
    print(f"ERROR: Unable to connect to DynamoDB: {e}")

try:
    # Récupérer tous les items
    response = table.scan()
    items = response.get("Items", [])
    print(f"{len(items)} items found. Deleting...")

    with table.batch_writer() as batch:
        for item in items:
            batch.delete_item(Key={"id": item["id"]})
            
    print("Table content wiped successfully.")
except Exception as e:
    print(f"Error during table cleanup : {e}")

try:
    with open(CSV_PATH, encoding="utf-8-sig") as f:
        reader = csv.DictReader(f, delimiter=';')

        with table.batch_writer() as batch:
            for row in reader:
                try:
                    item = {
                        "id": int(row["id"]),
                        "type": row["type"],
                        "message": row["message"],
                        "image": row["image"]
                    }
                    batch.put_item(Item=item)
                    print("Inserted:", item)
                except Exception as e:
                    print(f"Error inserting item {row}: {e}")
                    
    print("Data insertion completed successfully.")
except Exception as e:
    print(f"Error during data insertion: {e}")

    