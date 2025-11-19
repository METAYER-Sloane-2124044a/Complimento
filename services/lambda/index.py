import json

def get_handler_compliment(event, context):
    print("Event reçu:", event)  # utile pour debug dans CloudWatch / LocalStack logs

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Hello from Python Lambda!"
        })
    }