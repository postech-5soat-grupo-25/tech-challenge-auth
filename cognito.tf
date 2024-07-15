# Cognito User Pool
resource "aws_cognito_user_pool" "user_pool" {
  name = "tech-challenge-user-pool"

  lambda_config {
    pre_sign_up = aws_lambda_function.lambda_pre_signup.arn
  }
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "user_pool_client" {
  name              = "tech-challenge-app-client"
  user_pool_id      = aws_cognito_user_pool.user_pool.id
  generate_secret   = false
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
}


resource "aws_lambda_permission" "allow_cognito_invoke" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_pre_signup.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.user_pool.arn

  depends_on = [aws_cognito_user_pool.user_pool, aws_lambda_function.lambda_pre_signup]
}


# Cognito User Pool Group for Customers
resource "aws_cognito_user_group" "customers_group" {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  name   = "Kitchen"
  description  = "Group for kitchen employees"
}

# Cognito User Pool Group for Regular Users
resource "aws_cognito_user_group" "users_group" {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  name   = "Admins"
  description  = "Group for admins"
}