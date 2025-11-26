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

table_compliments = dynamodb.Table("compliments")
table_types = dynamodb.Table("types")

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
                "body": json.dumps({"message": "Paramètre 'type' manquant.", "image": ""})
            }

        type_selected = query_params['type']
        print("Type selected:", type_selected)

        # Trouver le type (dans table types)
        response_types = table_types.scan(
            FilterExpression=Attr('type').eq(type_selected)
        )

        print("Response types:", response_types)

        items_types = response_types.get("Items", [])
        print("Items types found:", items_types)

        if not items_types:
            return {
                "statusCode": 200,
                "headers": cors_headers,
                "body": json.dumps({
                    "message": "Je n'ai rien pour ce type... mais tu es incroyable !",
                    "image": ""
                })
            }

        type_item = items_types[0]  # celui trouvé
        type_id = type_item["id"]
        print("Type ID found:", type_id)

        type_image = type_item.get("image", "")

        # Trouver les compliments liés au type (dans table compliments)
        response_compliments = table_compliments.scan(
            FilterExpression=Attr('type').eq(type_id)
        )
        print("Response compliments:", response_compliments)

        compliments = response_compliments.get("Items", [])
        print("Compliments found:", compliments)

        if not compliments:
            return {
                "statusCode": 200,
                "headers": cors_headers,
                "body": json.dumps({
                    "message": "Aucun compliment trouvé pour ce type, mais tu es génial !",
                    "image": type_image
                })
            }

        # Sélection aléatoire d’un compliment
        compliment = random.choice(compliments)
        print("Selected random compliment:", compliment)

        message = compliment.get("message", "")

        # Retourner message + image associée au type
        return {
            "statusCode": 200,
            "headers": cors_headers,
            "body": json.dumps({
                "message": message,
                "image": type_image
            })
        }

    except Exception as e:
        print("Lambda error:", str(e))
        return {
            "statusCode": 500,
            "headers": cors_headers,
            "body": json.dumps({"message": str(e), "image": ""})
        }
