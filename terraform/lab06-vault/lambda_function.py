# lambda_function.py

import json

def lambda_handler(event, context):
    # Sample event data
    event_data = {
        'message': 'Hello from AWS Lambda!',
        'input_event': event
    }

    # Log the event data (optional)
    print("Received event:", json.dumps(event))

    # Construct a response JSON
    response = {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps(event_data)
    }

    return response