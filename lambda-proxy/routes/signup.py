import json
from aws_lambda_powertools import Logger

logger = Logger()

class SignUp():
    def __init__(self, boto_client, payload, cognito_client_id):
        self.boto_client = boto_client
        self.payload = payload
        self.cognito_client_id = cognito_client_id
    
    def signup(self):
        try:
            username = self.payload['username']
            password = self.payload['password']
            email = self.payload['email']
        except KeyError as e:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Please, provide email, username and password correctly'})
            }

        try:
            logger.info("Criando usuário")
            response = self.boto_client.sign_up(
                ClientId=self.cognito_client_id,
                Username=username,
                Password=password,
                UserAttributes=[
                    {
                        'Name': 'email',
                        'Value': email
                    }
                ]
            )

            logger.info(f"Usuário criado com sucesso {response}")
            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'User registered successfully'})
            }
        except self.boto_client.exceptions.UsernameExistsException:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'User already exists'})
            }
        except Exception as e:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': str(e)})
            }