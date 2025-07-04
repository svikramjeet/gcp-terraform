output "staging_cloud_run_app_url" {
  description = "URL of the staging Cloud Run app service"
  value       = google_cloud_run_v2_service.staging_app.uri
}

output "staging_cloud_run_worker_url" {
  description = "URL of the staging Cloud Run worker service"
  value       = google_cloud_run_v2_service.staging_worker_app.uri
}

output "staging_database_connection_name" {
  description = "Connection name for the staging database"
  value       = google_sql_database_instance.staging_db.connection_name
}

output "staging_database_ip" {
  description = "Public IP address of the staging database"
  value       = google_sql_database_instance.staging_db.public_ip_address
}

output "staging_storage_bucket_name" {
  description = "Name of the staging storage bucket"
  value       = google_storage_bucket.staging_bucket.name
}

output "staging_storage_bucket_url" {
  description = "URL of the staging storage bucket"
  value       = google_storage_bucket.staging_bucket.url
}

output "staging_cloud_run_service_account_email" {
  description = "Email of the staging Cloud Run service account"
  value       = google_service_account.staging_cloud_run_sa.email
}

output "staging_secret_db_password_id" {
  description = "Secret ID for the DB password"
  value       = google_secret_manager_secret.staging_db_password.id
}

output "staging_secret_db_password_version" {
  description = "Version of the DB password secret"
  value       = google_secret_manager_secret_version.staging_db_password_version.version
}
