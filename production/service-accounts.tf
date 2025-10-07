resource "google_service_account" "production_cloud_run_sa" {
  project      = var.project_id
  account_id   = var.cloud_run_sa_account_id
  display_name = "Production Cloud Run Service Account"
  description  = "Service account for production Cloud Run service created via terraform"
}

resource "google_service_account" "production_cloud_build_sa" {
  project      = var.project_id
  account_id   = var.cloud_build_sa_account_id
  display_name = "Production Cloud Build Service Account"
  description  = "Service account for production Cloud Build created via terraform"
}

resource "google_service_account" "production_cloud_run_job_sa" {
  project      = var.project_id
  account_id   = var.cloud_run_job_sa_account_id
  display_name = "Production Cloud Run Service Account"
  description  = "Service account for production Cloud Run Jobservice created via terraform"
}
