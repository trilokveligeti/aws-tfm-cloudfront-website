# Specify the provider and access details
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.aws_region}"
}

resource "time_static" "current_time" {}

resource "aws_s3_bucket" "s3_react_demo" {
  bucket = "${var.bucket_prefix}-${time_static.current_time.unix}"
  acl    = "private"
  region = "${var.aws_region}"
  force_destroy = true

  tags = {
    Name        = "React ToDo App"
    Environment = "${var.env}"
  }
}

resource "aws_s3_bucket_object" "root_files" {
  for_each = fileset("${var.app_folder}/", "**")

  bucket = "${aws_s3_bucket.s3_react_demo.bucket}"
  key    = each.value

  content_type = "${lookup(var.content_types, element(split(".", each.value) , length(split(".", each.value)) - 1), "binary/octet-stream")}"
  source = "${var.app_folder}/${each.value}"

  # etag makes the file update when it changes; see https://stackoverflow.com/questions/56107258/terraform-upload-file-to-s3-on-every-apply
  etag = filemd5("${var.app_folder}/${each.value}")
}



resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Default OAI"
}

data "aws_iam_policy_document" "s3_cf_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_react_demo.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [
      "${aws_s3_bucket.s3_react_demo.arn}",
      "${aws_s3_bucket.s3_react_demo.arn}/static",
      "${aws_s3_bucket.s3_react_demo.arn}/static/js/*",
      "${aws_s3_bucket.s3_react_demo.arn}/static/css/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "cf_dist_policy" {
  bucket = "${aws_s3_bucket.s3_react_demo.id}"
  policy = "${data.aws_iam_policy_document.s3_cf_policy.json}"
}

locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.s3_react_demo.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront S3 Distribution for Web App"
  default_root_object = "index.html"


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/static/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class =  "${var.cloudfront_price_class}"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US"]
    }
  }

  tags = {
    Environment = "${var.env}"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

