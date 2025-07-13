locals {
  cloud_run_roles = [
    "roles/cloudsql.client",
    "roles/storage.admin",
    "roles/secretmanager.secretAccessor",
    "roles/run.invoker",
    "roles/documentai.admin",
    "roles/errorreporting.admin",
    "roles/errorreporting.writer",
    "roles/logging.logWriter",
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.serviceAccountUser"
  ]

  cloud_build_roles = [
    "roles/run.admin",
    "roles/run.developer",
    "roles/iam.serviceAccountUser",
    "roles/storage.admin",
    "roles/artifactregistry.reader",
    "roles/artifactregistry.writer",
    "roles/artifactregistry.admin"
  ]

  cloud_run_job_roles = [
    "roles/editor",    
    "roles/secretmanager.secretAccessor"
  ]

  # Service account emails
  cloud_run_sa_email        = "${var.project_id}-cloud-run@${var.project_id}.iam.gserviceaccount.com"
  cloud_build_sa_email      = "${var.project_id}-cloud-build@${var.project_id}.iam.gserviceaccount.com"
  cloud_run_job_sa_email    = "${var.project_id}-run-jobs@${var.project_id}.iam.gserviceaccount.com"

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