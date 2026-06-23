output "website_url" {
  description = "The S3 bucket static website hosting endpoint URL"
  value       = "http://${aws_s3_bucket_website_configuration.website_config.website_endpoint}"
}