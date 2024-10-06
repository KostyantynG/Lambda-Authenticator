resource "aws_iam_role" "authenticator_lambda_role" {
  name = "${var.env}-${var.name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.authenticator_lambda_assume_role.json

  tags = var.tags
}

data "aws_iam_policy_document" "authenticator_lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]

  }
}

resource "aws_iam_policy" "authenticator_lambda_base_policy" {
  name = "${var.env}-${var.name}-lambda-base-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:ListTagsLogGroup",
          "logs:CreateLogGroup"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/*:*:*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "authenticator_lambda_base_policy_attachment" {
  role = aws_iam_role.authenticator_lambda_role.id
  policy_arn = aws_iam_policy.authenticator_lambda_base_policy.arn
}

resource "aws_iam_policy" "authenticator_lambda_dynamodb_read_only_policy" {
  name = "${var.env}-${var.name}-lambda-dynamodb-read-only-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "dynamodb:GetItem"
        ],
        "Effect" : "Allow",
        "Resource" : "${aws_dynamodb_table.credentials.arn}"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "authenticator_lambda_dynamodb_read_only_policy_attachment" {
  role = aws_iam_role.authenticator_lambda_role.id
  policy_arn = aws_iam_policy.authenticator_lambda_dynamodb_read_only_policy.arn
}

resource "aws_iam_policy" "authenticator_lambda_dynamodb_kms_decrypt_policy" {
  name = "${var.env}-${var.name}-lambda-dynamodb-kms-decrypt-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "kms:Decrypt"
        ],
        "Effect" : "Allow",
        "Resource" : "${aws_kms_key.dynamodb.arn}"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "authenticator_lambda_dynamodb_kms_decrypt_policy_attachment" {
  role = aws_iam_role.authenticator_lambda_role.id
  policy_arn = aws_iam_policy.authenticator_lambda_dynamodb_kms_decrypt_policy.arn
}