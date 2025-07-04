resource "google_cloud_run_v2_service" "production_app" {
  project  = var.project_id
  name     = var.cloud_run_app_name
  location = var.region

    lifecycle {
      ignore_changes = [
        template[0].annotations,
        template[0].containers[0].resources[0].limits["memory"],
        template[0].containers[0].name
      ]
  }

  template {
    service_account = google_service_account.production_cloud_run_sa.email

    annotations = {
      "run.googleapis.com/cloudsql-instances"     = google_sql_database_instance.production_db.connection_name
      "autoscaling.knative.dev/minScale"          = "1"
      "autoscaling.knative.dev/maxScale"          = "2"
    }

    volumes {
      name = "cloudsql"

      cloud_sql_instance {
        instances = [google_sql_database_instance.production_db.connection_name]
      }
    }


    containers {
      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }

      name = "rehuman-api-1"
      image = var.cloud_run_image

      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }

      env {
        name  = "LOG_CHANNEL"
        value = "stderr"
      }

      env {
        name = "QUEUE_NAME"
        value = "default"
      }

      env {
        name  = "APP_NAME"
        value = var.production_app_name
      }

      env {
        name  = "APP_ENV"
        value = "production"
      }

      env {
        name  = "APP_KEY"
        value = var.application_key
      }

      env {
        name  = "APP_DEBUG"
        value = "true"
      }

      env {
        name  = "APP_URL"
        value = var.production_app_name
      }

      env {
        name  = "QUEUE_CONNECTION"
        value = "database"
      }

      env {
        name  = "MAIL_FROM_ADDRESS"
        value = "hello@example.com"
      }

      env {
        name  = "MAIL_FROM_NAME"
        value = var.production_app_name
      }

      env {
        name = "POSTMARK_TOKEN"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.production_postmark_token.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "GOOGLE_CLIENT_ID"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.production_google_client_id.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "GOOGLE_CLIENT_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.production_google_client_secret.secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "GOOGLE_REDIRECT_URI"
        value = "GOOGLE_REDIRECT_URI"
      }

      env {
        name  = "DOCUMENT_AI_PROCESSOR_ID"
        value = "DOCUMENT_AI_PROCESSOR_ID"
      }

      env {
        name  = "DOCUMENT_AI_LOCATION"
        value = "DOCUMENT_AI_LOCATION"
      }

      env {
        name  = "GOOGLE_CLOUD_KEY_FILE"
        value = "GOOGLE_CLOUD_KEY_FILE"
      }

      env {
        name  = "GOOGLE_CLOUD_PROJECT_ID"
        value = var.project_id
      }

      env {
        name  = "GOOGLE_CLOUD_STORAGE_BUCKET"
        value = google_storage_bucket.production_bucket.name
      }

      env {
        name  = "STORAGE_BUCKET_URL"
        value = google_storage_bucket.production_bucket.url
      }

      env {
        name = "MICROSOFT_CLIENT_ID"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.production_microsoft_client_id.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "MICROSOFT_CLIENT_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.production_microsoft_client_secret.secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "MICROSOFT_REDIRECT_URI"
        value = "MICROSOFT_REDIRECT_URI"
      }

      env {
        name  = "MICROSOFT_TENANT_ID"
        value = "common"
      }

      env {
        name  = "CLOUD_SQL_CONNECTION_NAME"
        value = google_sql_database_instance.production_db.connection_name
      }

      env {
        name  = "DB_HOST"
        value = "/cloudsql/${google_sql_database_instance.production_db.connection_name}"
      }

      env {
        name  = "DB_NAME"
        value = google_sql_database.production_database.name
      }

      env {
        name  = "DB_USERNAME"
        value = google_sql_user.production_user.name
      }

      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.production_db_password.secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "DB_PORT"
        value = "5432"
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  depends_on = [google_project_service.required_apis]
}

resource "google_cloud_run_service_iam_member" "production_app_public" {
  location = google_cloud_run_v2_service.production_app.location
  service  = google_cloud_run_v2_service.production_app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# ------------------------------
# Worker Cloud Run Service
# ------------------------------
resource "google_cloud_run_v2_service" "production_worker_app" {
  project  = var.project_id
  name     = var.cloud_run_worker_name
  location = var.region

    lifecycle {
      ignore_changes = [
        template[0].annotations,
        template[0].containers[0].resources[0].limits["memory"],
        template[0].containers[0].name
      ]
  }

  template {
    service_account = google_service_account.production_cloud_run_sa.email

    annotations = {
      "run.googleapis.com/cloudsql-instances"     = google_sql_database_instance.production_db.connection_name
      "autoscaling.knative.dev/minScale"          = "1"
      "autoscaling.knative.dev/maxScale"          = "2"
    }

    volumes {
      name = "cloudsql"

      cloud_sql_instance {
        instances = [google_sql_database_instance.production_db.connection_name]
      }
    }


    containers {
      command = ["/var/www/html/cloud-run-worker-entrypoint"]
      image = var.cloud_run_image

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }


      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }

      env {
        name  = "LOG_CHANNEL"
        value = "stderr"
      }

      env {
        name = "QUEUE_NAME"
        value = "default"
      }

      env {
        name  = "APP_NAME"
        value = var.production_app_name
      }

      env {
        name  = "APP_ENV"
        value = "production"
      }

      env {
        name  = "APP_KEY"
        value = var.application_key
      }

      env {
        name  = "APP_DEBUG"
        value = "true"
      }

      env {
        name  = "APP_URL"
        value = var.production_app_name
      }

      env {
        name  = "QUEUE_CONNECTION"
        value = "database"
      }

      env {
        name  = "MAIL_FROM_ADDRESS"
        value = "hello@example.com"
      }

      env {
        name  = "MAIL_FROM_NAME"
        value = var.production_app_name
      }

      env {
        name = "POSTMARK_TOKEN"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.production_postmark_token.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "GOOGLE_CLIENT_ID"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.production_google_client_id.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "GOOGLE_CLIENT_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.production_google_client_secret.secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "GOOGLE_REDIRECT_URI"
        value = "URI/social-signup/callback"
      }

      env {
        name  = "DOCUMENT_AI_PROCESSOR_ID"
        value = "DOCUMENT_AI_PROCESSOR_ID"
      }

      env {
        name  = "DOCUMENT_AI_LOCATION"
        value = "DOCUMENT_AI_LOCATION"
      }

      env {
        name  = "GOOGLE_CLOUD_KEY_FILE"
        value = "GOOGLE_CLOUD_KEY_FILE"
      }

      env {
        name  = "GOOGLE_CLOUD_PROJECT_ID"
        value = var.project_id
      }

      env {
        name  = "GOOGLE_CLOUD_STORAGE_BUCKET"
        value = google_storage_bucket.production_bucket.name
      }

      env {
        name  = "STORAGE_BUCKET_URL"
        value = google_storage_bucket.production_bucket.url
      }

      env {
        name = "MICROSOFT_CLIENT_ID"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.production_microsoft_client_id.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "MICROSOFT_CLIENT_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.production_microsoft_client_secret.secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "MICROSOFT_REDIRECT_URI"
        value = "URI/social-signup/outlook/callback"
      }

      env {
        name  = "MICROSOFT_TENANT_ID"
        value = "common"
      }

      env {
        name  = "CLOUD_SQL_CONNECTION_NAME"
        value = google_sql_database_instance.production_db.connection_name
      }

      env {
        name  = "DB_HOST"
        value = "/cloudsql/${google_sql_database_instance.production_db.connection_name}"
      }

      env {
        name  = "DB_NAME"
        value = google_sql_database.production_database.name
      }

      env {
        name  = "DB_USERNAME"
        value = google_sql_user.production_user.name
      }

      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.production_db_password.secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "DB_PORT"
        value = "5432"
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  depends_on = [google_project_service.required_apis]
}

resource "google_cloud_run_service_iam_member" "production_worker_app_public" {
  location = google_cloud_run_v2_service.production_worker_app.location
  service  = google_cloud_run_v2_service.production_worker_app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
