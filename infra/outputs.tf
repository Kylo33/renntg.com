output "website_bucket_name" {
  value       = aws_s3_bucket.static-site.bucket
}

output "website_bucket_region" {
  value       = aws_s3_bucket.static-site.bucket_region
}

output "resume_bucket_name" {
  value       = aws_s3_bucket.resume.bucket
}

output "resume_bucket_region" {
  value       = aws_s3_bucket.resume.bucket_region
}
