# Resource /produtos
resource "aws_api_gateway_resource" "produtos" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "produtos"
}

# POST method for /produtos
resource "aws_api_gateway_method" "produtos_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.produtos.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# Integration for /produtos POST
resource "aws_api_gateway_integration" "produtos_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.produtos.id
  http_method             = aws_api_gateway_method.produtos_post.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lambda_proxy.invoke_arn
}

# GET method for /produtos
resource "aws_api_gateway_method" "produtos_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.produtos.id
  http_method   = "GET"
  authorization = "NONE"

}

# Integration for /produtos GET
resource "aws_api_gateway_integration" "produtos_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.produtos.id
  http_method             = aws_api_gateway_method.produtos_get.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lambda_proxy.invoke_arn
}

# Resource /produtos/{id}
resource "aws_api_gateway_resource" "produto_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.produtos.id
  path_part   = "{id}"
}

# GET method for /produtos/{id}
resource "aws_api_gateway_method" "produto_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.produto_id.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integration for /produtos/{id} GET
resource "aws_api_gateway_integration" "produto_id_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.produto_id.id
  http_method             = aws_api_gateway_method.produto_id_get.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lambda_proxy.invoke_arn
}