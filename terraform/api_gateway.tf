resource "aws_apigatewayv2_api" "http_api_gateway" {
  name          = "${var.env}-${var.name}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["https://editor.swagger.io"]
    allow_methods = ["POST"]
    allow_headers = ["content-type", "authorization"]
    max_age = 3600
  }

  tags = var.tags
}

resource "aws_apigatewayv2_integration" "authenticator_lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api_gateway.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.authenticator_lambda.arn
  integration_method = "POST"

  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "authenticator_lambda_api_route" {
  api_id    = aws_apigatewayv2_api.http_api_gateway.id
  route_key = "POST /auth"

  target = "integrations/${aws_apigatewayv2_integration.authenticator_lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.http_api_gateway.id
  name        = var.env
  auto_deploy = true

  tags = var.tags
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authenticator_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api_gateway.execution_arn}/*/*"
}

output "api_gateway_invoke_url" {
  description = "Invoke URL of the API Gateway for specific environment"
  value       = "${aws_apigatewayv2_stage.api_stage.invoke_url}"
}