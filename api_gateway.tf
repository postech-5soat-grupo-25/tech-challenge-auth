# API Gateway Rest API
resource "aws_api_gateway_rest_api" "api" {
  name = "tech-challenge-api"
}

# Deploy API
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.signup_integration,
    aws_api_gateway_integration.login_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}

# Cognito Authorizer
resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name            = "cognito-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.api.id
  identity_source = "method.request.header.Authorization"
  provider_arns   = [aws_cognito_user_pool.user_pool.arn]
  type            = "COGNITO_USER_POOLS"
}
