resource "aws_servicecatalogappregistry_application" "resume" {
  name = "resume"
}

resource "aws_s3_bucket" "resume" {
  bucket        = "${var.resume_subdomain}.${var.domain_name}"
  force_destroy = true
  tags = aws_servicecatalogappregistry_application.resume.application_tag
}

resource "aws_s3_bucket_public_access_block" "resume" {
  bucket = aws_s3_bucket.resume.id
}

resource "aws_s3_bucket_policy" "resume-public-read" {
  bucket     = aws_s3_bucket.resume.id
  policy     = data.aws_iam_policy_document.resume-public-read-get-object.json
  depends_on = [aws_s3_bucket_public_access_block.resume]
}
data "aws_iam_policy_document" "resume-public-read-get-object" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.resume.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_website_configuration" "resume" {
  bucket = aws_s3_bucket.resume.id
  index_document {
    suffix = "index.pdf"
  }
}

resource "cloudflare_dns_record" "resume" {
  name    = "${var.resume_subdomain}"
  type    = "CNAME"
  content = aws_s3_bucket_website_configuration.resume.website_endpoint

  ttl     = 1
  proxied = true
  zone_id = data.cloudflare_zone.main.id
}

