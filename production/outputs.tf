output "production_cloud_run_app_url" {
  description = "URL of the production Cloud Run app service"
  value       = google_cloud_run_v2_service.production_app.uri
}

output "production_cloud_run_worker_url" {
  description = "URL of the production Cloud Run worker service"
  value       = google_cloud_run_v2_service.production_worker_app.uri
}

output "production_database_connection_name" {
  description = "Connection name for the production database"
  value       = google_sql_database_instance.production_db.connection_name
}

output "production_database_ip" {
  description = "Public IP address of the production database"
  value       = google_sql_database_instance.production_db.public_ip_address
}

output "production_storage_bucket_name" {
  description = "Name of the production storage bucket"
  value       = google_storage_bucket.production_bucket.name
}

output "production_storage_bucket_url" {
  description = "URL of the production storage bucket"
  value       = google_storage_bucket.production_bucket.url
}

output "production_cloud_run_service_account_email" {
  description = "Email of the production Cloud Run service account"
  value       = google_service_account.production_cloud_run_sa.email
}

output "production_secret_db_password_id" {
  description = "Secret ID for the DB password"
  value       = google_secret_manager_secret.production_db_password.id
}

output "production_secret_db_password_version" {
  description = "Version of the DB password secret"
  value       = google_secret_manager_secret_version.production_db_password_version.version
}
