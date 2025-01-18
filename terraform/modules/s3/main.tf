variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "test-bucket"  # Default for testing
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "test"  # Default for testing
}

resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "bucket_name" {
  value = aws_s3_bucket.main.id
}

output "bucket_arn" {
  value = aws_s3_bucket.main.arn
}
