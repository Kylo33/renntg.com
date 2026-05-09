terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
  backend "s3" {
    bucket = "renntg.com-tfstate-099660946013-us-east-1-an"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "cloudflare" {}

# S3 Website Bucket

resource "aws_s3_bucket" "static-site" {
  bucket        = "renntg.com"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.static-site.id
}

resource "aws_s3_bucket_policy" "public-read" {
  bucket     = aws_s3_bucket.static-site.id
  policy     = data.aws_iam_policy_document.public-read-get-object.json
  depends_on = [aws_s3_bucket_public_access_block.default]
}

data "aws_iam_policy_document" "public-read-get-object" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static-site.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_website_configuration" "default" {
  bucket = aws_s3_bucket.static-site.id
  index_document {
    suffix = "index.html"
  }
}

output "website_bucket_name" {
  description = "AWS S3 Website Bucket Name"
  value       = aws_s3_bucket.static-site.bucket
}

output "website_bucket_region" {
  description = "Region where S3 Bucket is Located"
  value       = aws_s3_bucket.static-site.bucket_region
}

# WWW redirect

resource "aws_s3_bucket" "www" {
  bucket        = "www.renntg.com"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "www" {
  bucket = aws_s3_bucket.www.id
  redirect_all_requests_to {
    host_name = "renntg.com"
  }
}

# DNS

data "cloudflare_zone" "renntg" {
  filter = {
    name = "renntg.com"
  }
}

resource "cloudflare_dns_record" "default" {
  name    = "renntg.com"
  type    = "CNAME"
  content = aws_s3_bucket_website_configuration.default.website_endpoint

  ttl     = 1
  proxied = true
  zone_id = data.cloudflare_zone.renntg.id
}

resource "cloudflare_dns_record" "www" {
  name    = "www"
  type    = "CNAME"
  content = aws_s3_bucket_website_configuration.www.website_endpoint

  ttl     = 1
  proxied = true
  zone_id = data.cloudflare_zone.renntg.id
}
