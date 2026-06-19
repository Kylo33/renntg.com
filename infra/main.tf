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

data "cloudflare_zone" "main" {
  filter = {
    name = var.domain_name
  }
}

# myApplication

resource "aws_servicecatalogappregistry_application" "personal_website" {
  name = "renntg.com"
  description = "Personal Website and Portfolio"
}

# S3 Website Bucket

resource "aws_s3_bucket" "static-site" {
  bucket        = var.domain_name
  force_destroy = true
  tags = aws_servicecatalogappregistry_application.personal_website.application_tag
}

resource "aws_s3_bucket_public_access_block" "static-site" {
  bucket = aws_s3_bucket.static-site.id
}

resource "aws_s3_bucket_policy" "static-site-public-read" {
  bucket     = aws_s3_bucket.static-site.id
  policy     = data.aws_iam_policy_document.static-site-public-read-get-object.json
  depends_on = [aws_s3_bucket_public_access_block.static-site]
}

data "aws_iam_policy_document" "static-site-public-read-get-object" {
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

resource "aws_s3_bucket_website_configuration" "static-site" {
  bucket = aws_s3_bucket.static-site.id
  index_document {
    suffix = "index.html"
  }
}

resource "cloudflare_dns_record" "static-site" {
  name    = var.domain_name
  type    = "CNAME"
  content = aws_s3_bucket_website_configuration.static-site.website_endpoint

  ttl     = 1
  proxied = true
  zone_id = data.cloudflare_zone.main.id
}

# WWW redirect

resource "aws_s3_bucket" "www" {
  bucket        = "www.${var.domain_name}"
  force_destroy = true
  tags = aws_servicecatalogappregistry_application.personal_website.application_tag
}

resource "aws_s3_bucket_website_configuration" "www" {
  bucket = aws_s3_bucket.www.id
  redirect_all_requests_to {
    host_name = var.domain_name
  }
}

resource "cloudflare_dns_record" "www" {
  name    = "www"
  type    = "CNAME"
  content = aws_s3_bucket_website_configuration.www.website_endpoint

  ttl     = 1
  proxied = true
  zone_id = data.cloudflare_zone.main.id
}

