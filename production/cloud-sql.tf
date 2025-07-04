resource "random_password" "production_db_password" {
  length  = 32
  special = true
}

resource "google_secret_manager_secret" "production_db_password" {
  project   = var.project_id
  secret_id = var.db_password_secret_name

  replication {
    auto {}
  }

  depends_on = [google_project_service.required_apis]
}

resource "google_secret_manager_secret_version" "production_db_password_version" {
  secret      = google_secret_manager_secret.production_db_password.id
  secret_data = random_password.production_db_password.result
}

resource "google_sql_database_instance" "production_db" {
  project              = var.project_id
  name                 = var.db_instance_name
  database_version     = "POSTGRES_17"
  region               = var.region
  deletion_protection  = false

  settings {
    edition                      = "ENTERPRISE"
    tier                         = var.db_instance_tier
    deletion_protection_enabled  = false

    disk_type          = "PD_SSD"  
    disk_size          = 10     
    availability_type  = "ZONAL"

    ip_configuration {
      ipv4_enabled = true
    }

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = true

      backup_retention_settings {
        retained_backups = 7
      }
    }

    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }
  }

  depends_on = [google_project_service.required_apis]
}

resource "google_sql_database" "production_database" {
  project  = var.project_id
  name     = var.db_name
  instance = google_sql_database_instance.production_db.name
}

resource "google_sql_user" "production_user" {
  project  = var.project_id
  name     = var.db_user
  instance = google_sql_database_instance.production_db.name
  password = random_password.production_db_password.result
}
