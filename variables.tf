variable "access_key" {
  description = "Access Key for CLI Account"
  default = ""
}

variable "secret_key" {
  description = "Key for CLI Account"
  default = ""
}

variable "deploy_env" {
  description = "Deployment Environment for the App"
  default = "lab"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-2"
}

variable "bucket_prefix" {
  default = ""
}
variable "cloudfront_price_class" {
  default = "PriceClass_200"
}

variable "env" {
  default = "Dev"
}

variable "content_types" {
  type = "map"
  default = {
    html = "text/html"
    png = "image/png"
    jpeg = "image/jpeg"
    jpg = "image/jpeg"
    js = "text/javascript"
    css = "text/css"
    "ico" = "image/vnd.microsoft.icon"
    "json" = "application/json"
    "txt" = "text"
  }
}

variable "app_folder" {
  default = ""
}
