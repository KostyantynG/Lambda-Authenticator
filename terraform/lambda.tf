resource "aws_lambda_function" "authenticator_lambda" {
  function_name    = "${var.env}-${var.name}-function"
  role             = aws_iam_role.authenticator_lambda_role.arn
  timeout          = 30
  filename         = data.archive_file.app_code.output_path
  source_code_hash = data.archive_file.app_code.output_base64sha256
  runtime          = "python3.12"
  architectures    = ["arm64"]
  handler          = "main.lambda_handler"
  memory_size      = 256

  environment {
    variables = {
      AUTHENTICATOR_TABLE_NAME               = aws_dynamodb_table.credentials.name
    }
  }

  tags = var.tags
}

data "archive_file" "app_code" {
  type = "zip"
  source_dir = "../src/lambda_authenticator/package"
  output_path = "./lambda_handler.zip"
}