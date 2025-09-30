resource "google_project_iam_member" "staging_cloud_run_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.staging_cloud_run_sa.email}"
}

# Use bucket-specific permissions instead of storage admin for security
# resource "google_project_iam_member" "staging_cloud_run_storage_admin" {
#   project = var.project_id
#   role    = "roles/storage.admin"
#   member  = "serviceAccount:${google_service_account.staging_cloud_run_sa.email}"
# }

# Bucket-specific IAM binding for Cloud Run service account
resource "google_storage_bucket_iam_member" "staging_cloud_run_bucket_object_admin" {
  bucket = google_storage_bucket.staging_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.staging_cloud_run_sa.email}"
}

resource "google_project_iam_member" "staging_cloud_run_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.staging_cloud_run_sa.email}"
}

resource "google_project_iam_member" "staging_cloud_build_developer" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_service_account.staging_cloud_build_sa.email}"
}

resource "google_project_iam_member" "staging_cloud_build_run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.staging_cloud_build_sa.email}"
}

# Use bucket-specific permissions instead of storage admin for security
# resource "google_project_iam_member" "staging_cloud_build_storage_admin" {
#   project = var.project_id
#   role    = "roles/storage.admin"
#   member  = "serviceAccount:${google_service_account.staging_cloud_build_sa.email}"
# }

# Bucket-specific IAM binding for Cloud Build service account
resource "google_storage_bucket_iam_member" "staging_cloud_build_bucket_object_admin" {
  bucket = google_storage_bucket.staging_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.staging_cloud_build_sa.email}"
}

resource "google_project_iam_member" "staging_cloud_build_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.staging_cloud_build_sa.email}"
}
