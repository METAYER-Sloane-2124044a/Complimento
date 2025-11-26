import boto3
import json
import os
from botocore.exceptions import ClientError

dynamodb = boto3.resource(
    "dynamodb",
    endpoint_url=os.environ["ENDPOINT_URL_LAMBDA"],
    region_name=os.environ["REGION_NAME"]
)

table_compliments = dynamodb.Table("compliments")

cors_headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'OPTIONS,DELETE'
}

def delete_handler_compliment(event, context):
    if event['httpMethod'] == 'OPTIONS':
        return {'statusCode': 200, 'headers': cors_headers, 'body': ''}
    
    if event['httpMethod'] != 'DELETE':
        return {
            "statusCode": 405, # Method Not Allowed
            "headers": cors_headers,
            "body": json.dumps({"error": "Méthode non autorisée. Utilisez DELETE."})
        }
    
    print("Event received for deletion:", event)

    # Get queryStringParameters
    path_params = event.get('pathParameters')
    
    if not path_params or 'id' not in path_params:
        return {
            "statusCode": 400,
            "headers": cors_headers,
            "body": json.dumps({"error": "Paramètre 'id' manquant."})
        }
    
    # Get the compliment ID to delete
    compliment_id = int(path_params['id'])

    try:
        print(f"Attempting to delete ID: {compliment_id}")

        # Delete the compliment item
        table_compliments.delete_item(Key={'id': compliment_id})

        return {
            "statusCode": 200,
            "headers": cors_headers,
            "body": json.dumps({"message": "Compliment supprimé avec succès !"})
        }
    except Exception as e:
        print(f"Error deleting item: {e}")
        return {
            "statusCode": 500,
            "headers": cors_headers,
            "body": json.dumps({"error": "Internal Server Error"})
        }