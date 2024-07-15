import json
import os
import boto3
import requests
from routes.login import Login
from routes.signup import SignUp
from utils.get_user_groups import TokenHandler
from aws_lambda_powertools import Logger

logger = Logger(service="LambdaProxy")

@logger.inject_lambda_context(log_event=True)
def lambda_handler(event, context):
    try:
        user_pool_id = os.environ["USER_POOL_ID"]
        client_id = os.environ["CLIENT_ID"]
        pedidos_produtos_lb_url = os.environ["PEDIDOS_PRODUTOS_LB_URL"]

        resource = event.get('resource', '')
        http_method = event.get('httpMethod', '')
        query_string_parameters = event.get('queryStringParameters', '')
        path_parameters = event.get('pathParameters', '')
        headers = event.get("headers")
        body = event.get('body', "")

        logger.info(f"Received event with resource: {resource}, method: {http_method}")

        if body:
            body = json.loads(body)
            logger.debug(f"Request body: {body}")
    except Exception as e:
        logger.error(f"Error reading environment variables: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Internal Server Error'})
        }

    try:

        client = boto3.client('cognito-idp')
        get_user_groups_util = TokenHandler(event, user_pool_id)

        if resource == '/signup':
            logger.info("Iniciando fluxo de signup")
            signup_route = SignUp(client, body, client_id)
            result = signup_route.signup()
            return result

        elif resource == '/login':
            logger.info("Iniciando fluxo de login")
            login_route = Login(client, body, client_id)
            result = login_route.login()
            return result

        elif resource == '/pedidos':
            user_groups = get_user_groups_util.get_user_groups()
            if http_method == 'GET' and not path_parameters and not query_string_parameters:
                try:
                    logger.info(f"Fetching pedidos from {pedidos_produtos_lb_url}{resource}")
                    response = requests.get(f"{pedidos_produtos_lb_url}{resource}")
                    logger.info(f"Pedidos response: {response.status_code}, {response.text}")
                    response.raise_for_status()
                except requests.RequestException as e:
                    logger.error(f"Error fetching pedidos: {e}")
                    return {
                        'statusCode': 500,
                        'body': json.dumps({'message': 'Internal Server Error'})
                    }
                return {
                    'statusCode': response.status_code,
                    'body': response.text,
                    'headers': {
                        'Content-Type': 'application/json'
                    }
                }

        elif resource == '/produtos':
            if http_method == 'GET' and not path_parameters and not query_string_parameters:
                try:
                    logger.info(f"Fetching produtos from {pedidos_produtos_lb_url}{resource}")
                    response = requests.get(f"{pedidos_produtos_lb_url}{resource}")
                    logger.info(f"Produtos response: {response.status_code}, {response.text}")
                    response.raise_for_status()
                    response_json = response.json()
                except requests.RequestException as e:
                    logger.error(f"Error fetching produtos: {e}")
                    return {
                        'statusCode': 500,
                        'body': json.dumps({'message': 'Internal Server Error'})
                    }
                return {
                    'statusCode': response.status_code,
                    'body': json.dumps(response_json),
                    'headers': {
                        'Content-Type': 'application/json'
                    }
                }

            elif http_method == 'POST':
                if not body:
                    logger.warning("Empty body in produto creation request")
                    return {
                        'statusCode': 400,
                        'body': json.dumps({'message': 'Empty body'})
                    }
    
                required_fields = ['nome', 'foto', 'descricao', 'categoria', 'preco', 'ingredientes']
                if not all(field in body for field in required_fields):
                    logger.warning("Missing required fields in produto creation request")
                    return {
                        'statusCode': 400,
                        'body': json.dumps({'message': 'Missing required fields'})
                    }
                user_groups = get_user_groups_util.get_user_groups()
                logger.info(f"User groups: {user_groups}")
                if "Admins" not in user_groups:
                    logger.warning("User is not an admin")
                    return {
                        'statusCode': 403,
                        'body': json.dumps({'message': 'Forbidden'})
                    }
                try:
                    logger.info(f"Creating produto at {pedidos_produtos_lb_url}{resource}")
                    response = requests.post(f"{pedidos_produtos_lb_url}{resource}", json=body, headers={'Content-Type': 'application/json', 'UserGroup': "Admin"})
                    logger.info(f"Create produto response: {response.status_code}, {response.text}")
                    response.raise_for_status()
                    response_json = response.json()
                except requests.RequestException as e:
                    logger.error(f"Error creating produto: {e}")
                    return {
                        'statusCode': 500,
                        'body': json.dumps({'message': 'Internal Server Error'})
                    }
                return {
                    'statusCode': response.status_code,
                    'body': json.dumps(response_json),
                    'headers': {
                        'Content-Type': 'application/json'
                    }
                }

        elif resource.startswith('/produtos/') and '{id}' in resource:
            if http_method == 'GET' and path_parameters and not query_string_parameters:
                product_id = path_parameters.get('id')
                try:
                    logger.info(f"Fetching produto with id {product_id} from {pedidos_produtos_lb_url}/produtos/{product_id}")
                    response = requests.get(f"{pedidos_produtos_lb_url}/produtos/{product_id}")
                    logger.info(f"Produto response: {response.status_code}, {response.text}")
                    response.raise_for_status()
                    response_json = response.json()
                except requests.exceptions.HTTPError as http_err:
                    if response.status_code == 404:
                        logger.error(f"Produto with id {product_id} not found: {http_err}")
                        return {
                            'statusCode': 404,
                            'body': json.dumps({'message': f'Produto with id {product_id} not found'})
                        }
                    else:
                        logger.error(f"HTTP error occurred: {http_err}")
                        return {
                            'statusCode': response.status_code,
                            'body': json.dumps({'message': 'HTTP error occurred'})
                        }
                except requests.RequestException as e:
                    logger.error(f"Error fetching produto with id {product_id}: {e}")
                    return {
                        'statusCode': 500,
                        'body': json.dumps({'message': 'Internal Server Error'})
                    }
                return {
                    'statusCode': response.status_code,
                    'body': json.dumps(response_json),
                    'headers': {
                        'Content-Type': 'application/json'
                    }
                }

        logger.warning(f"Resource {resource} not found")
        return {
            'statusCode': 404,
            'body': json.dumps({'message': 'Not Found'})
        }

    except Exception as e:
        logger.error(f"Unhandled exception: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Internal Server Error'})
        }
