import json
import boto3
import random
import base64
import os

# Set up the AWS clients
bedrock_client = boto3.client("bedrock-runtime", region_name="us-east-1")
s3_client = boto3.client("s3")

# Define the model ID and S3 bucket name (replace with your actual bucket name)
MODEL_ID = "amazon.titan-image-generator-v1"
BUCKET_NAME = os.environ["BUCKET_NAME"]

PREFIX = 11

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        prompt = body.get('prompt', 'Default prompt if not provided')
        
        seed = random.randint(0, 2147483647)
        s3_image_path = f"{PREFIX}/generated_images/titan_{seed}.png"
        
        native_request = {
            "taskType": "TEXT_IMAGE",
            "textToImageParams": {"text": prompt},
            "imageGenerationConfig": {
                "numberOfImages": 1,
                "quality": "standard",
                "cfgScale": 8.0,
                "height": 1024,
                "width": 1024,
                "seed": seed,
            }
        }
        
        response = bedrock_client.invoke_model(modelId=MODEL_ID, body=json.dumps(native_request))
        model_response = json.loads(response["body"].read())
        
        # Extract and decode the Base64 image data
        base64_image_data = model_response["images"][0]
        image_data = base64.b64decode(base64_image_data)
        
        # Upload the decoded image data to S3
        s3_client.put_object(Bucket=BUCKET_NAME, Key=s3_image_path, Body=image_data)
    
        return {
            "statusCode": 200,
            "body": json.dumps("Image generated and uploaded successfully")
        }
        
    except Exception as e:
        return {
            "statusCode": 500, 
            "body": json.dumps(f"An error occurred: {str(e)}")
        }
