resource "google_artifact_registry_repository" "docker_repo" {
  project       = var.project_id
  provider      = google
  location      = var.region
  repository_id = "docker"
  format        = "DOCKER"

  docker_config {
    immutable_tags = false
  }
}