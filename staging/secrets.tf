resource "google_secret_manager_secret" "staging_postmark_token" {
  project   = var.project_id
  secret_id = var.postmark_token_secret_name

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "staging_postmark_token_version" {
  secret      = google_secret_manager_secret.staging_postmark_token.id
  secret_data = var.postmark_token_secret_value
}

resource "google_secret_manager_secret" "staging_google_client_id" {
  project   = var.project_id
  secret_id = var.google_client_id_secret_name

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "staging_google_client_id_version" {
  secret      = google_secret_manager_secret.staging_google_client_id.id
  secret_data = var.google_client_id_secret_value
}

resource "google_secret_manager_secret" "staging_google_client_secret" {
  project   = var.project_id
  secret_id = var.google_client_secret_secret_name

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "staging_google_client_secret_version" {
  secret      = google_secret_manager_secret.staging_google_client_secret.id
  secret_data = var.google_client_secret_secret_value
}

resource "google_secret_manager_secret" "staging_microsoft_client_id" {
  project   = var.project_id
  secret_id = var.microsoft_client_id_secret_name

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "staging_microsoft_client_id_version" {
  secret      = google_secret_manager_secret.staging_microsoft_client_id.id
  secret_data = var.microsoft_client_id_secret_value
}

resource "google_secret_manager_secret" "staging_microsoft_client_secret" {
  project   = var.project_id
  secret_id = var.microsoft_client_secret_secret_name

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "staging_microsoft_client_secret_version" {
  secret      = google_secret_manager_secret.staging_microsoft_client_secret.id
  secret_data = var.microsoft_client_secret_secret_value
}

# Grant Cloud Run service account access to secrets
resource "google_secret_manager_secret_iam_member" "staging_secrets_access" {
  for_each = {
    db_password         = google_secret_manager_secret.staging_db_password.id
    postmark_token      = google_secret_manager_secret.staging_postmark_token.id
    google_client_id    = google_secret_manager_secret.staging_google_client_id.id
    google_client_secret = google_secret_manager_secret.staging_google_client_secret.id
    microsoft_client_id = google_secret_manager_secret.staging_microsoft_client_id.id
    microsoft_client_secret = google_secret_manager_secret.staging_microsoft_client_secret.id
  }

  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.staging_cloud_run_sa.email}"
}

