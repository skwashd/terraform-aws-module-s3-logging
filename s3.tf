data "aws_iam_policy_document" "bucket" {

  ## Common
  statement {
    sid = "IAM"
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.id}:root"]
      type        = "AWS"
    }
  }

  statement {
    sid = "LogDeliveryCheckAcl"

    actions = ["s3:GetBucketAcl"]

    resources = [
      aws_s3_bucket.this.arn,
    ]

    principals {
      type = "Service"
      identifiers = [
        "delivery.logs.amazonaws.com",
        "logdelivery.elasticloadbalancing.amazonaws.com",
      ]
    }
  }

  ## ALB
  dynamic "statement" {
    for_each = var.services["alb"] ? [true] : []

    content {
      sid = "AlbAccessLegacy"

      actions = [
        "s3:PutObject"
      ]

      resources = [
        "${aws_s3_bucket.this.arn}/alb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      ]

      principals {
        identifiers = [data.aws_elb_service_account.main.arn]
        type        = "AWS"
      }
    }
  }

  dynamic "statement" {
    for_each = var.services["alb"] ? [true] : []

    content {
      sid = "AlbAccessModern"

      actions = [
        "s3:PutObject"
      ]
      resources = [
        "${aws_s3_bucket.this.arn}/alb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      ]

      principals {
        identifiers = ["delivery.logs.amazonaws.com"]
        type        = "Service"
      }

      condition {
        test     = "StringEquals"
        values   = ["bucket-owner-full-control"]
        variable = "s3:x-amz-acl"
      }
    }
  }

  dynamic "statement" {
    for_each = var.services["alb"] ? [true] : []

    content {
      sid = "AlbAclCheck"
      actions = [
        "s3:GetBucketAcl"
      ]
      resources = [
        aws_s3_bucket.this.arn
      ]

      principals {
        identifiers = ["delivery.logs.amazonaws.com"]
        type        = "Service"
      }
    }
  }

  ## Cloudfront
  dynamic "statement" {
    for_each = var.services["cloudfront"] ? [true] : []

    content {
      sid = "AWSLogDeliveryCloudfront"
      actions = [
        "s3:PutObject"
      ]
      resources = [
        "${aws_s3_bucket.this.arn}/cloudfront/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      ]

      condition {
        test     = "StringEquals"
        variable = "s3:x-amz-acl"
        values   = ["bucket-owner-full-control"]
      }

      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values = [
          data.aws_caller_identity.current.account_id
        ]
      }

      condition {
        test     = "ArnLike"
        variable = "aws:SourceArn"
        values = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:delivery-source*"
        ]
      }

      principals {
        type        = "Service"
        identifiers = ["delivery.logs.amazonaws.com"]
      }
    }
  }

  ## S3
  dynamic "statement" {
    for_each = var.services["s3"] ? [true] : []

    content {
      sid = "S3ServerAccess"
      actions = [
        "s3:PutObject"
      ]
      resources = [
        "${aws_s3_bucket.this.arn}/s3/*",
      ]

      principals {
        identifiers = [
          "logging.s3.amazonaws.com"
        ]
        type = "Service"
      }

      condition {
        test     = "ArnLike"
        variable = "aws:SourceArn"
        values = [
          "arn:aws:s3:::${var.prefix}-${data.aws_caller_identity.current.account_id}-*"
        ]
      }

      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values = [
          data.aws_caller_identity.current.account_id
        ]
      }
    }
  }

  ## VPC Flows
  dynamic "statement" {
    for_each = var.services["vpc"] ? [true] : []

    content {
      sid = "AWSLogDeliveryVpc"
      actions = [
        "s3:PutObject"
      ]
      resources = [
        "${aws_s3_bucket.this.arn}/vpc/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      ]

      condition {
        test     = "StringEquals"
        variable = "s3:x-amz-acl"
        values   = ["bucket-owner-full-control"]
      }

      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values = [
          data.aws_caller_identity.current.account_id
        ]
      }

      condition {
        test     = "ArnLike"
        variable = "aws:SourceArn"
        values = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:delivery-source*"
        ]
      }

      principals {
        type        = "Service"
        identifiers = ["delivery.logs.amazonaws.com"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.services["cloudfront"] || var.services["vpc"] ? [true] : []
    content {
      sid = "AWSLogDeliveryAclCheck"
      actions = [
        "s3:GetBucketAcl"
      ]
      resources = [
        aws_s3_bucket.this.arn
      ]

      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values = [
          data.aws_caller_identity.current.account_id
        ]
      }

      condition {
        test     = "ArnLike"
        variable = "aws:SourceArn"
        values = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:delivery-source*"
        ]
      }

      principals {
        type        = "Service"
        identifiers = ["delivery.logs.amazonaws.com"]
      }
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket.json

  depends_on = [
    aws_s3_bucket_public_access_block.this
  ]
}

# tfsec:ignore:aws-s3-enable-bucket-logging This is a logging bucket. We can't enable logging on it.
resource "aws_s3_bucket" "this" {
  bucket        = local.bucket_name
  force_destroy = false

  tags = var.tags
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = "log-delivery-write"

  depends_on = [
    aws_s3_bucket_ownership_controls.this
  ]
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "IAAfter30Days"
    status = "Enabled"

    filter {}

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }

  rule {
    id     = "PurgeOldVersions30Days"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  rule {
    id     = "GlacierAfter90Days"
    status = "Enabled"

    filter {}

    transition {
      days          = 90
      storage_class = "DEEP_ARCHIVE"
    }
  }

  rule {
    id     = "PurgeAfter1Year"
    status = "Enabled"

    filter {}

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      #tfsec:ignore:aws-s3-enable-encryption This is a logging bucket. We can't enable encryption on it.
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}
