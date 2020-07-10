output "bucket-name" {
  value = "${aws_s3_bucket.s3_react_demo.bucket_domain_name}"
}

output "cloudfront-dns" {
  value = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
}