resource "aws_lambda_function" "lambda_pre_signup" {
  filename         = "dummy_lambda_package.zip"
  function_name    = "LambdaPreSignUp"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = filebase64sha256("dummy_lambda_package.zip")

  environment {
    variables = {
      STAGE = "prod"
    }
  }
}