variable "credentials_file" {
  description = "Path to the GCP credentials file"
  type        = string
}

variable "project_name" {
  description = "Name of the GCP project"
  type        = string
}

variable "project_id" {
  description = "ID of the GCP project"
  type        = string
}

variable "billing_account_id" {
  description = "GCP billing account ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "europe-west2"
}

variable "environment" {
  description = "Environment name (e.g. dev, production, prod)"
  type        = string
  default     = "production"
}

# Application & Cloud Run
variable "production_app_name" {
  description = "Name of the production application"
  type        = string
}

variable "cloud_run_service_name" {
  description = "Name of the Cloud Run service"
  type        = string
}

variable "cloud_run_app_name" {
  description = "Name of the Cloud Run application"
  type        = string
}

variable "cloud_run_worker_name" {
  description = "Name of the Cloud Run worker service"
  type        = string
}

variable "cloud_run_image" {
  description = "Docker image for the main app"
  type        = string
}

variable "cloud_run_worker_image" {
  description = "Docker image for the worker app"
  type        = string
}

variable "application_key" {
  description = "Application encryption key"
  type        = string
  sensitive   = true
}

# Cloud SQL
variable "db_instance_name" {
  description = "Name of the Cloud SQL instance"
  type        = string
}

variable "db_instance_tier" {
  description = "Cloud SQL machine type (e.g., db-f1-micro)"
  type        = string
  default     = "db-f1-micro"
}

variable "db_name" {
  description = "Name of the default database"
  type        = string
}

variable "db_user" {
  description = "Username for the database user"
  type        = string
}

variable "db_password_secret_name" {
  description = "Secret Manager secret name for the DB password"
  type        = string
}

# Secret Manager - Application secrets
variable "postmark_token_secret_name" {
  description = "Secret name for Postmark token"
  type        = string
}

variable "postmark_token_secret_value" {
  description = "Value for Postmark token"
  type        = string
  sensitive   = true
}

variable "google_client_id_secret_name" {
  description = "Secret name for Google client ID"
  type        = string
}

variable "google_client_id_secret_value" {
  description = "Value for Google client ID"
  type        = string
  sensitive   = true
}

variable "google_client_secret_secret_name" {
  description = "Secret name for Google client secret"
  type        = string
}

variable "google_client_secret_secret_value" {
  description = "Value for Google client secret"
  type        = string
  sensitive   = true
}

variable "microsoft_client_id_secret_name" {
  description = "Secret name for Microsoft client ID"
  type        = string
}

variable "microsoft_client_id_secret_value" {
  description = "Value for Microsoft client ID"
  type        = string
  sensitive   = true
}

variable "microsoft_client_secret_secret_name" {
  description = "Secret name for Microsoft client secret"
  type        = string
}

variable "microsoft_client_secret_secret_value" {
  description = "Value for Microsoft client secret"
  type        = string
  sensitive   = true
}

# Cloud Storage
variable "bucket_name" {
  description = "Name of the GCS bucket"
  type        = string
}

variable "bucket_location" {
  description = "GCS bucket region"
  type        = string
  default     = "europe-west2" # London
}

# GitHub for Cloud Build triggers
variable "github_owner" {
  description = "GitHub user or organization"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

# Service accounts
variable "cloud_run_sa_account_id" {
  description = "Account ID for the Cloud Run service account"
  type        = string
}

variable "cloud_build_sa_account_id" {
  description = "Account ID for the Cloud Build service account"
  type        = string
}

variable "cloud_run_min_instances" {
  description = "Minimum number of Cloud Run instances"
  type        = number
  default     = 1
}

variable "cloud_run_max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 2
}

