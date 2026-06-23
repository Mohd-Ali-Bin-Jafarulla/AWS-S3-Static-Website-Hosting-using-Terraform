
# ------------------1. Provision the S3 Bucket-------------------
resource "aws_s3_bucket" "website" {
  bucket        = var.bucket_name
  force_destroy = true # Allows a clean 'terraform destroy' even with files inside

  tags = var.tags
}

# ------------------2. Open Public Access (Required for public-facing web hosting)-------------------
resource "aws_s3_bucket_public_access_block" "website_public_access" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# ------------------3. Enable Static Website Hosting Properties-------------------
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# ------------------4. Attach the Public Read Policy (Read-Only access for anonymous traffic)-------------------
resource "aws_s3_bucket_policy" "allow_public_access" {
  depends_on = [aws_s3_bucket_public_access_block.website_public_access]
  bucket     = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

# ------------------5. Render index.html inline via Terraform-------------------
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  content_type = "text/html"
  content      = <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome To My Site</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; text-align: center; margin-top: 120px; background-color: #f8f9fa; color: #212529; }
        .card { max-width: 500px; margin: 0 auto; background: white; padding: 40px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        h1 { color: #0078d4; margin-bottom: 10px; }
        p { color: #6c757d; font-size: 1.1em; }
    </style>
</head>
<body>
    <div class="card">
        <h1>🚀 Hello, World!</h1>
        <p>This static website was fully provisioned and uploaded entirely via <strong>Terraform</strong> inside VS Code.</p>
    </div>
</body>
</html>
EOF
}

# ------------------6. Render error.html inline via Terraform-------------------
resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.website.id
  key          = "error.html"
  content_type = "text/html"
  content      = <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 Not Found</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; text-align: center; margin-top: 120px; background-color: #fff5f5; color: #212529; }
        .card { max-width: 500px; margin: 0 auto; background: white; padding: 40px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); border-top: 4px solid #e53e3e; }
        h1 { color: #e53e3e; }
        p { color: #4a5568; margin-bottom: 20px; }
        a { color: #3182ce; text-decoration: none; font-weight: bold; }
    </style>
</head>
<body>
    <div class="card">
        <h1>🔍 404 - Page Not Found</h1>
        <p>Oops! The page you are trying to visit does not exist.</p>
        <a href="index.html">← Return Home</a>
    </div>
</body>
</html>
EOF
}