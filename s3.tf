# Create S3 Bucket
resource "aws_s3_bucket" "complimento_bucket" {
  bucket = "complimento-bucket"
}

# S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.complimento_bucket.bucket
  index_document {
    suffix = var.INDEX_PAGE
  }
  error_document {
    key = var.INDEX_PAGE
  }
}

# Template HTML for compliments.html
data "template_file" "compliments_html" {
  template = file("${path.module}/web/compliments.html.tpl")
  vars = {
    base_api_url   = "${var.ENDPOINT_URL}/restapis/${aws_api_gateway_rest_api.lambda.id}/dev/_user_request_/compliment",
    base_image_url = "${var.DIR_IMG_S3}/"
  }
}

# HTML / CSS Files
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.complimento_bucket.id
  key          = "index.html"
  content      = file("${path.module}/web/index.html")
  content_type = "text/html"
}

# HTML generated from template
resource "aws_s3_object" "compliments_html" {
  bucket       = aws_s3_bucket.complimento_bucket.id
  key          = "compliments.html"
  content      = data.template_file.compliments_html.rendered
  content_type = "text/html"
}

# CSS File
resource "aws_s3_object" "style_css" {
  bucket       = aws_s3_bucket.complimento_bucket.id
  key          = "style/style.css"
  content      = file("${path.module}/web/style/style.css")
  content_type = "text/css"
  etag         = filemd5("${path.module}/web/style/style.css")
}

# ---- Image Files ----
resource "aws_s3_object" "image_cute" {
  bucket       = aws_s3_bucket.complimento_bucket.id
  key          = "${var.DIR_IMG_S3}/cute.jpg"
  source       = "${path.module}/${var.PATH_IMG_LOCAL}/cute.jpg"
  content_type = "image/jpeg"
  etag         = filemd5("${path.module}/${var.PATH_IMG_LOCAL}/cute.jpg")
}

resource "aws_s3_object" "image_motivation" {
  bucket       = aws_s3_bucket.complimento_bucket.id
  key          = "${var.DIR_IMG_S3}/motivation.jpg"
  source       = "${path.module}/${var.PATH_IMG_LOCAL}/motivation.jpg"
  content_type = "image/jpeg"
  etag         = filemd5("${path.module}/${var.PATH_IMG_LOCAL}/motivation.jpg")
}

resource "aws_s3_object" "image_romantique" {
  bucket       = aws_s3_bucket.complimento_bucket.id
  key          = "${var.DIR_IMG_S3}/romantique.jpg"
  source       = "${path.module}/${var.PATH_IMG_LOCAL}/romantique.jpg"
  content_type = "image/jpeg"
  etag         = filemd5("${path.module}/${var.PATH_IMG_LOCAL}/romantique.jpg")
}

resource "aws_s3_object" "image_drole" {
  bucket       = aws_s3_bucket.complimento_bucket.id
  key          = "${var.DIR_IMG_S3}/drole.jpg"
  source       = "${path.module}/${var.PATH_IMG_LOCAL}/drole.jpg"
  content_type = "image/jpeg"
  etag         = filemd5("${path.module}/${var.PATH_IMG_LOCAL}/drole.jpg")
}

resource "aws_s3_object" "image_fond" {
  bucket       = aws_s3_bucket.complimento_bucket.id
  key          = "${var.DIR_IMG_S3}/fond.jpg"
  source       = "${path.module}/${var.PATH_IMG_LOCAL}/fond.jpg"
  content_type = "image/jpeg"
  etag         = filemd5("${path.module}/${var.PATH_IMG_LOCAL}/fond.jpg")
}

resource "aws_s3_object" "image_fond2" {
  bucket       = aws_s3_bucket.complimento_bucket.id
  key          = "${var.DIR_IMG_S3}/fond2.jpg"
  source       = "${path.module}/${var.PATH_IMG_LOCAL}/fond2.jpg"
  content_type = "image/jpeg"
  etag         = filemd5("${path.module}/${var.PATH_IMG_LOCAL}/fond2.jpg")
}

# S3 Bucket Policy to allow public read access
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.complimento_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource = [
          "${aws_s3_bucket.complimento_bucket.arn}/*",
        ],
      },
    ],
  })
  depends_on = [aws_s3_bucket_public_access_block.public_access_block]
}

# S3 Bucket Public Access Block Configuration
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.complimento_bucket.id

  block_public_acls       = false
  block_public_policy     = true
  ignore_public_acls      = false
  restrict_public_buckets = false
}