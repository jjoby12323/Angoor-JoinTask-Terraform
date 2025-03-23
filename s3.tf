resource "aws_s3_bucket" "private_bucket" {
  bucket = "angoor-private-bucket"
  force_destroy = true

  tags = {
    Name        = "Private Bucket"
    Environment = "dev"
  }
}

resource "aws_s3_bucket" "public_bucket" {
  bucket = "angoor-public-bucket"
  force_destroy = true

  tags = {
    Name        = "Public Bucket"
    Environment = "dev"
  }
}

# Allow public access (you must explicitly unblock it)
resource "aws_s3_bucket_public_access_block" "public_bucket_block" {
  bucket                  = aws_s3_bucket.public_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Public read policy for the bucket
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.public_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.public_bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.public_bucket_block]
}