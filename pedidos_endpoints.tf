# Resource /pedidos
resource "aws_api_gateway_resource" "pedidos" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "pedidos"
}

# POST method for /pedidos
resource "aws_api_gateway_method" "pedidos_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.pedidos.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# Integration for /pedidos POST
resource "aws_api_gateway_integration" "pedidos_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.pedidos.id
  http_method             = aws_api_gateway_method.pedidos_post.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lambda_proxy.invoke_arn
}

# GET method for /pedidos
resource "aws_api_gateway_method" "pedidos_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.pedidos.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# Integration for /pedidos GET
resource "aws_api_gateway_integration" "pedidos_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.pedidos.id
  http_method             = aws_api_gateway_method.pedidos_get.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lambda_proxy.invoke_arn
}

# Resource /pedidos/{id}
resource "aws_api_gateway_resource" "pedido_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.pedidos.id
  path_part   = "{id}"
}

# GET method for /pedidos/{id}
resource "aws_api_gateway_method" "pedido_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.pedido_id.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# Integration for /pedidos/{id} GET
resource "aws_api_gateway_integration" "pedido_id_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.pedido_id.id
  http_method             = aws_api_gateway_method.pedido_id_get.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lambda_proxy.invoke_arn
}





# Resource /pedidos/pagamento
resource "aws_api_gateway_resource" "pedidos_pagamento" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.pedidos.id
  path_part   = "pagamento"
}

# POST method for /pedidos/pagamento
resource "aws_api_gateway_method" "pedidos_pagamento_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.pedidos_pagamento.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# Integration for /pedidos/pagamento POST
resource "aws_api_gateway_integration" "pedidos_pagamento_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.pedidos_pagamento.id
  http_method             = aws_api_gateway_method.pedidos_pagamento_post.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:739842188003:function:LambdaPagamentos:prod/invocations"
}