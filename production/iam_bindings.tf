locals {
  cloud_run_roles = [
    "roles/cloudsql.client",
    "roles/storage.admin",
    "roles/secretmanager.secretAccessor",
    "roles/run.invoker",
    "roles/documentai.apiAdmin",
    "roles/errorreporting.admin",
    "roles/errorreporting.writer",
    "roles/logging.logWriter",
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.serviceAccountUser"
  ]

  cloud_build_roles = [
    "roles/run.admin",
    "roles/run.developer",
    "roles/run.invoker",
    "roles/cloudsql.client",
    "roles/documentai.apiAdmin",
    "roles/errorreporting.admin",
    "roles/errorreporting.writer",
    "roles/logging.logWriter",
    "roles/secretmanager.secretAccessor",
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.serviceAccountUser",
    "roles/storage.admin",
    "roles/artifactregistry.reader",
    "roles/artifactregistry.writer"
  ]

  # Service account emails
  cloud_run_sa_email   = "cloudrun-sa@${var.project_id}.iam.gserviceaccount.com"
  cloud_build_sa_email = "${var.project_number}@cloudbuild.gserviceaccount.com"
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

resource "google_service_account_iam_member" "firebase_adminsdk_token_creator" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${local.cloud_run_sa_email}"
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:firebase-adminsdk-fbsvc@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_service_account_iam_member" "firebase_fcm_token_creator" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${local.cloud_run_sa_email}"
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:fcm-push@${var.project_id}.iam.gserviceaccount.com"
}
