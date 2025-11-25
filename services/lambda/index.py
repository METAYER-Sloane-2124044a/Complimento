import boto3
import json
import os
import random

from boto3.dynamodb.conditions import Attr

dynamodb = boto3.resource(
    "dynamodb",
    endpoint_url=os.environ["ENDPOINT_URL_LAMBDA"],
    region_name=os.environ["REGION_NAME"]
)

table = dynamodb.Table("compliments")

cors_headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
}

def get_handler_compliment(event, context):
    try:
        print("Event received:", event)

        query_params = event.get('queryStringParameters')
        if not query_params or 'type' not in query_params:
            return {
                "statusCode": 400,
                "headers": cors_headers,
                "body": json.dumps({"message": "Paramètre 'type' manquant dans la requête.", "image": ""})
            }
        
        type_selected = query_params['type']
        print("Type selected :", type_selected)

        print("Table : ", table)

        response = table.scan(
                            FilterExpression=Attr('type').eq(type_selected)
                            )
        
        print("Response : ", response)

        items = response.get("Items", [])

        if not items:
            print("Items is empty")
            return {
                "statusCode": 200,
                "headers": cors_headers,
                "body": json.dumps({
                    "message": "Je n'ai rien à te proposer pour ce type de compliment...sorry...tu es incroyable !",
                    "image": ""
                })
            }
        
        random_item = random.choice(items)
        print("Item :", random_item)
            
        # Return the corresponding message and image
        return {
            "statusCode": 200,
            "headers": cors_headers,
            "body": json.dumps({
                "message": random_item.get("message", ""),
                "image": random_item.get("image", "")
            })
        }

    except Exception as e:
        print("Lambda error:", str(e))
        return {
            "statusCode": 500,
            "headers": cors_headers,
            "body": json.dumps({"message": str(e), "image": ""})
        }