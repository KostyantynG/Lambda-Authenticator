resource "aws_s3_bucket" "tf_backend" {
  bucket = "${var.env}-${var.name}-terraform-backend"
  force_destroy = var.env == "dev" ? true : false

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "tf_backend_bucket_versionning" {
  bucket = aws_s3_bucket.tf_backend.id

    versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "tf_backend_tsl_only_policy" {
  bucket = aws_s3_bucket.tf_backend.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSSLRequestsOnly",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": [
        "${aws_s3_bucket.tf_backend.arn}",
        "${aws_s3_bucket.tf_backend.arn}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      },
      "Principal": "*"
    }
  ]
}
POLICY
}