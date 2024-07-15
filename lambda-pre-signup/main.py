from aws_lambda_powertools import Logger
import json

logger = Logger(service="LambdaPreSignup")

def lambda_handler(event, context):
    try:
        logger.info(str(event))
        event['response']['autoConfirmUser'] = True  # Auto confirma o usuário
        event['response']['autoVerifyEmail'] = True  # Auto verifica o e-mail
    except Exception as e:
        logger.error(e)
        raise e
    
    logger.info("Pre signup executado com sucesso")
    return event