# Notification Channels for Production Environment
resource "google_monitoring_notification_channel" "production_email" {
  display_name = "Production Email Alerts"
  type         = "email"
  labels = {
    email_address = var.alert_email_address
  }
  enabled = true
}

resource "google_monitoring_notification_channel" "production_email_critical" {
  display_name = "Production Critical Email Alerts"
  type         = "email"
  labels = {
    email_address = var.critical_alert_email_address
  }
  enabled = true
}

# Cloud Run Service Uptime Check
resource "google_monitoring_uptime_check_config" "production_app_uptime" {
  display_name     = "Production App Uptime Check"
  timeout          = "10s"
  period           = "60s"
  selected_regions = ["USA", "EUROPE"]

  http_check {
    path         = "/health"
    port         = "443"
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = "${var.cloud_run_app_name}-${random_id.bucket_suffix.hex}.a.run.app"
    }
  }

  checker_type = "STATIC_IP_CHECKERS"
}

# Alerting Policy for Cloud Run Service Down
resource "google_monitoring_alert_policy" "production_service_down" {
  display_name = "Production Cloud Run Service Down"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Cloud Run service is down"

    condition_threshold {
      filter          = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.cloud_run_app_name}\""
      duration        = "300s"
      comparison      = "COMPARISON_LESS_THAN"
      threshold_value = 1

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["resource.labels.service_name"]
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.production_email_critical.name
  ]

  alert_strategy {
    auto_close = "1800s"
  }
}

# Alerting Policy for High Error Rate
resource "google_monitoring_alert_policy" "production_high_error_rate" {
  display_name = "Production High Error Rate"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "High error rate in Cloud Run service"

    condition_threshold {
      filter          = "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/request_count\" AND metric.labels.response_code_class!=\"2xx\""
      duration        = "300s"
      comparison      = "COMPARISON_GREATER_THAN"
      threshold_value = 10

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["resource.labels.service_name"]
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.production_email.name
  ]

  alert_strategy {
    auto_close = "1800s"
  }
}

# Alerting Policy for Cloud SQL High CPU
resource "google_monitoring_alert_policy" "production_sql_high_cpu" {
  display_name = "Production Cloud SQL High CPU"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Cloud SQL instance high CPU usage"

    condition_threshold {
      filter          = "resource.type=\"cloudsql_database\" AND metric.type=\"cloudsql.googleapis.com/database/cpu/utilization\""
      duration        = "300s"
      comparison      = "COMPARISON_GREATER_THAN"
      threshold_value = 0.8

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.production_email.name
  ]

  alert_strategy {
    auto_close = "1800s"
  }
}

# Alerting Policy for Failed Authentication Attempts
resource "google_monitoring_alert_policy" "production_failed_auth" {
  display_name = "Production Failed Authentication Attempts"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "High number of failed authentication attempts"

    condition_threshold {
      filter          = "resource.type=\"cloud_run_revision\" AND jsonPayload.message=~\"authentication failed|login failed|unauthorized\""
      duration        = "300s"
      comparison      = "COMPARISON_GREATER_THAN"
      threshold_value = 20

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.production_email.name
  ]

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content = "High number of failed authentication attempts detected. This could indicate a brute force attack or misconfigured authentication."
  }
}

# Alerting Policy for Secret Manager Access
resource "google_monitoring_alert_policy" "production_secret_access" {
  display_name = "Production Unusual Secret Manager Access"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Unusual Secret Manager access pattern"

    condition_threshold {
      filter          = "protoPayload.serviceName=\"secretmanager.googleapis.com\" AND protoPayload.methodName=\"google.cloud.secretmanager.v1.SecretManagerService.AccessSecretVersion\""
      duration        = "300s"
      comparison      = "COMPARISON_GREATER_THAN"
      threshold_value = 100

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.production_email.name
  ]

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content = "Unusual pattern of Secret Manager access detected. Review the access logs to ensure legitimate usage."
  }
}

# Log-based metric for application errors
resource "google_logging_metric" "production_application_errors" {
  name   = "production_application_errors"
  filter = "resource.type=\"cloud_run_revision\" AND (severity=\"ERROR\" OR jsonPayload.level=\"error\")"

  metric_descriptor {
    metric_kind  = "COUNTER"
    value_type   = "INT64"
    display_name = "Production Application Errors"
  }

  label_extractors = {
    service_name = "EXTRACT(resource.labels.service_name)"
  }
}

# Alerting Policy for Application Errors
resource "google_monitoring_alert_policy" "production_application_errors" {
  display_name = "Production Application Error Rate"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "High application error rate"

    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/production_application_errors\""
      duration        = "300s"
      comparison      = "COMPARISON_GREATER_THAN"
      threshold_value = 5

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.production_email.name
  ]

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content = "High application error rate detected. Check application logs for details."
  }

  depends_on = [google_logging_metric.production_application_errors]
}