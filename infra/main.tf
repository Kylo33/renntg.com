terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
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

resource "aws_s3_bucket" "static-site" {
  bucket_namespace = "account-regional"
  force_destroy    = true
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
  value = aws_s3_bucket.static-site.bucket
}

output "website_bucket_region" {
  description = "Region where S3 Bucket is Located"
  value = aws_s3_bucket.static-site.bucket_region
}
