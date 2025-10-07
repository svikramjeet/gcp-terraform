resource "google_storage_bucket" "production_bucket" {
  name          = var.bucket_name
  location      = var.region

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

  depends_on = [google_project_service.required_apis]
}

resource "google_storage_bucket_iam_member" "production_bucket_admin" {
  bucket = google_storage_bucket.production_bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.production_cloud_run_sa.email}"
}

resource "google_storage_bucket_iam_member" "production_bucket_public_read" {
  bucket = google_storage_bucket.production_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
