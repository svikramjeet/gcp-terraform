# IAM roles for Cloud Run service account
locals {
  cloud_run_roles = {
    sql_client      = "roles/cloudsql.client"
    storage_admin   = "roles/storage.admin"
    secret_accessor = "roles/secretmanager.secretAccessor"
  }

  cloud_build_roles = {
    developer      = "roles/cloudbuild.builds.builder"
    run_developer  = "roles/run.developer"
    storage_admin  = "roles/storage.admin"
    sa_user        = "roles/iam.serviceAccountUser"
  }
}

resource "google_project_iam_member" "cloud_run_bindings" {
  for_each = local.cloud_run_roles

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.production_cloud_run_sa.email}"
}

resource "google_project_iam_member" "cloud_build_bindings" {
  for_each = local.cloud_build_roles

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.production_cloud_build_sa.email}"
}
