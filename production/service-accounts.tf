resource "google_service_account" "production_cloud_run_sa" {
  project      = var.project_id
  account_id   = var.cloud_run_sa_account_id
  display_name = "production Cloud Run Service Account"
  description  = "Service account for production Cloud Run service"
}

resource "google_service_account" "production_cloud_build_sa" {
  project      = var.project_id
  account_id   = var.cloud_build_sa_account_id
  display_name = "production Cloud Build Service Account"
  description  = "Service account for production Cloud Build"
}