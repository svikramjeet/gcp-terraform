resource "google_storage_bucket" "staging_bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30
    }
  }

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

  depends_on = [google_project_service.required_apis]
}

resource "google_storage_bucket_iam_member" "staging_bucket_admin" {
  bucket = google_storage_bucket.staging_bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.staging_cloud_run_sa.email}"
}

resource "google_storage_bucket_iam_member" "staging_bucket_public_read" {
  bucket = google_storage_bucket.staging_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
