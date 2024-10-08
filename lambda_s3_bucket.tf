resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "lambda-proxy-deploy"
}


resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}