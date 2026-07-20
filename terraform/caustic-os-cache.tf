resource "random_id" "caustic_os_cache_bucket_id" {
  byte_length = 6
}

resource "minio_s3_bucket" "caustic_os_cache" {
  bucket         = "caustic-os-cache-${random_id.caustic_os_cache_bucket_id.hex}"
  acl            = "private"
  object_locking = false
}
