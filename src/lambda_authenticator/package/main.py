import os
import json
import base64
import bcrypt
import boto3
import logging
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_dynamodb_table():
    dynamodb = boto3.resource('dynamodb')
    authenticator_table_name = os.getenv('AUTHENTICATOR_TABLE_NAME')
    return dynamodb.Table(authenticator_table_name)

def lambda_handler(event, context):
    logger.info("Event: %s", json.dumps(event))

    try:
        # Get Authorization header, considering both cases for first symbol
        auth_header = event['headers'].get('Authorization') or event['headers'].get('authorization', '')
        logger.debug("Authorization header: %s", auth_header)

        if not auth_header.startswith('Basic '):
            logger.error("Missing or invalid Authorization header")
            return {"statusCode": 401, "body": json.dumps("Missing or invalid Authorization header")}

        # Decode the Base64-encoded credentials
        base64_credentials = auth_header.split(' ')[1]
        try:
            credentials = base64.b64decode(base64_credentials).decode('utf-8')
            username, password = credentials.split(':')
            if not username or not password:
                logger.error("Username or password cannot be empty")
                return {"statusCode": 400, "body": json.dumps("Username or password cannot be empty")}

            logger.info("Username extracted from header: %s", username)
        except (IndexError, ValueError, base64.binascii.Error) as e:
            logger.error("Error decoding credentials: %s", str(e))
            return {"statusCode": 400, "body": json.dumps("Invalid credentials format")}

        try:
            table = get_dynamodb_table()
            response = table.get_item(Key={'username': username})
            if 'Item' not in response:
                logger.warning("Username not found in database: %s", username)
                return {"statusCode": 403, "body": json.dumps("Invalid username or password")}

            password_hash = response['Item']['password_hash']

            # Verify password
            if bcrypt.checkpw(password.encode('utf-8'), password_hash.encode('utf-8')):
                logger.info("Authentication successful for user: %s", username)
                return {"statusCode": 200, "body": json.dumps("Authentication successful")}
            else:
                logger.warning("Invalid username or password for user: %s", username)
                return {"statusCode": 403, "body": json.dumps("Invalid username or password")}

        except ClientError as e:
            logger.error("DynamoDB error: %s", str(e))
            return {"statusCode": 503, "body": json.dumps("Service is currently unavailable. Please try again later.")}

    except Exception as e:
        logger.error("Unexpected error: %s", str(e))
        return {"statusCode": 400, "body": json.dumps(f"Error: {str(e)}")}
