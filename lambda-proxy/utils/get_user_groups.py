import json
import jwt
from aws_lambda_powertools import Logger

logger = Logger()

class TokenHandler():
    def __init__(self, event, user_pool_id):
        self.event = event
        self.user_pool_id = user_pool_id

    def get_user_groups(self):
        try:
            token = self.event['headers']['Authorization']
        except Exception as e:
            logger.error(f"Error reading token from headers: {e}")
            raise e
        
        try:
            decoded_token = jwt.decode(token, options={"verify_signature": False})
        except jwt.InvalidTokenError as e:
            return {
                'statusCode': 401,
                'body': json.dumps('Token inválido')
            }
        
        try:
            groups = decoded_token.get("cognito:groups")
            if not groups:
                raise Exception("User doesn't have any group")
        except Exception as e:
            raise e

        return groups