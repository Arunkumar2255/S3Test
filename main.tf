resource "aws_s3_bucket" "main" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  tags          = merge({
    Name = var.bucket_name
  }, var.tags)
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.bucket

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_logging" "main" {
  bucket        = aws_s3_bucket.main.bucket
  target_bucket = var.log_bucket_name
  target_prefix = "log/"
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.bucket

  rule {
    id      = "log"
    enabled = true
    prefix  = "log/"
    status  = "Enabled"

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket        = var.log_bucket_name
  force_destroy = true
  acl           = "log-delivery-write"
  tags          = merge({
    Name = var.log_bucket_name
  }, var.tags)

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.bucket

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::123456789012:user/some-user"]
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}
