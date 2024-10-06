resource "aws_kms_key" "dynamodb" {
  description             = "This key is used to encrypt DynamoDB table"
  deletion_window_in_days = 7

  enable_key_rotation = true

  tags = var.tags
}