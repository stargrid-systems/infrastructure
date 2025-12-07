resource "random_id" "terraform_state_bucket_id" {
  byte_length = 6
}

resource "minio_s3_bucket" "terraform_state" {
  bucket         = "tf-state-${random_id.terraform_state_bucket_id.hex}"
  acl            = "private"
  object_locking = true
}

resource "minio_s3_bucket_versioning" "terraform_state" {
  bucket = minio_s3_bucket.terraform_state.bucket

  versioning_configuration {
    status = "Enabled"
  }
}
