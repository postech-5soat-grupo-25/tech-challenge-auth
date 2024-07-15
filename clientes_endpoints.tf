# Resource /clientes
resource "aws_api_gateway_resource" "clientes" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "clientes"
}

# POST method for /clientes
resource "aws_api_gateway_method" "clientes_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.clientes.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# Integration for /clientes POST
resource "aws_api_gateway_integration" "clientes_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.clientes.id
  http_method             = aws_api_gateway_method.clientes_post.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lambda_proxy.invoke_arn
}
