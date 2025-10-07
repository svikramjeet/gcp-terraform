terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Single provider since the project already exists
provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
}

# Enable required APIs in the existing project
resource "google_project_service" "required_apis" {
  for_each = toset([
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "clouderrorreporting.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "firebase.googleapis.com",
    "firebasehosting.googleapis.com",
    "fcm.googleapis.com",
    "firebaseinappmessaging.googleapis.com",
    "firebaseremoteconfig.googleapis.com",
    "firebaseextensions.googleapis.com",
    "firebaseappdistribution.googleapis.com",
    "fcmregistrations.googleapis.com"
  ])

  project = var.project_id
  service = each.value

  disable_dependent_services = true
  disable_on_destroy         = false
}
