import boto3
import json
import os
from boto3.dynamodb.conditions import Attr


def get_handler_compliment(event, context):
    try:
        print("Event received:", event)

        type_selected = event['queryStringParameters']['type']
        print("Type selected :", type_selected)

        dynamodb = boto3.resource(
            "dynamodb",
            endpoint_url=os.environ["ENDPOINT_URL_LAMBDA"],
            region_name=os.environ["REGION_NAME"],
            aws_access_key_id=os.environ["AWS_ACCESS_KEY_ID"],
            aws_secret_access_key=os.environ["AWS_SECRET_ACCESS_KEY"]
        )

        table = dynamodb.Table("compliments")
        print("Table : ", table)

        response = table.scan(
                            FilterExpression=Attr('type').eq(type_selected)
                            )
        
        print("Response : ", response)

        items = response.get("Items") or []

        if not items:
            print("Items is empty")
            return {
                "statusCode": 200,
                "body": json.dumps({
                    "message": "Je n'ai rien à te proposer pour ce type de compliment...sorry...tu es incroyable !",
                    "image": ""
                })
            }
        
        random_item = items[0]
        print("Item :", random_item)
            
        # Return the corresponding message and image
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": random_item.get("message", ""),
                "image": random_item.get("image", "")
            })
        }

    except Exception as e:
        print("Lambda error:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"message": str(e)})
        }