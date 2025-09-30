locals {
  cloud_run_roles = [
    "roles/cloudsql.client",
    "roles/secretmanager.secretAccessor",
    "roles/run.invoker",
    "roles/documentai.editor",
    "roles/errorreporting.writer",
    "roles/logging.logWriter"
  ]

  cloud_build_roles = [
    "roles/run.developer",
    "roles/iam.serviceAccountUser",
    "roles/artifactregistry.writer"
  ]

  cloud_run_job_roles = [
    "roles/secretmanager.secretAccessor",
    "roles/logging.logWriter",
    "roles/cloudsql.client"
  ]

  # Service account emails
  cloud_run_sa_email     = "${var.project_id}-cloud-run@${var.project_id}.iam.gserviceaccount.com"
  cloud_build_sa_email   = "${var.project_id}-cloud-build@${var.project_id}.iam.gserviceaccount.com"
  cloud_run_job_sa_email = "${var.project_id}-run-jobs@${var.project_id}.iam.gserviceaccount.com"

}

resource "google_project_iam_member" "cloud_run_iam" {
  for_each = toset(local.cloud_run_roles)

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${local.cloud_run_sa_email}"
}

resource "google_project_iam_member" "cloud_build_iam" {
  for_each = toset(local.cloud_build_roles)

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${local.cloud_build_sa_email}"
}


resource "google_project_iam_member" "cloud_run_job_iam" {
  for_each = toset(local.cloud_run_job_roles)

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${local.cloud_run_job_sa_email}"
}

# Bucket-specific IAM bindings for Cloud Run service account
resource "google_storage_bucket_iam_member" "cloud_run_bucket_object_admin" {
  bucket = google_storage_bucket.production_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${local.cloud_run_sa_email}"
}

# Bucket-specific IAM bindings for Cloud Build service account
resource "google_storage_bucket_iam_member" "cloud_build_bucket_object_admin" {
  bucket = google_storage_bucket.production_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${local.cloud_build_sa_email}"
}