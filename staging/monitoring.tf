# Notification Channels for Staging Environment
resource "google_monitoring_notification_channel" "staging_email" {
  display_name = "Staging Email Alerts"
  type         = "email"
  labels = {
    email_address = var.alert_email_address
  }
  enabled = true
}

# Cloud Run Service Uptime Check
resource "google_monitoring_uptime_check_config" "staging_app_uptime" {
  display_name     = "Staging App Uptime Check"
  timeout          = "10s"
  period           = "300s" # Less frequent checks for staging
  selected_regions = ["USA"]

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
resource "google_monitoring_alert_policy" "staging_service_down" {
  display_name = "Staging Cloud Run Service Down"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Cloud Run service is down"

    condition_threshold {
      filter          = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.cloud_run_app_name}\""
      duration        = "600s" # Longer duration for staging
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
    google_monitoring_notification_channel.staging_email.name
  ]

  alert_strategy {
    auto_close = "3600s"
  }
}

# Alerting Policy for High Error Rate (higher threshold for staging)
resource "google_monitoring_alert_policy" "staging_high_error_rate" {
  display_name = "Staging High Error Rate"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "High error rate in Cloud Run service"

    condition_threshold {
      filter          = "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/request_count\" AND metric.labels.response_code_class!=\"2xx\""
      duration        = "600s"
      comparison      = "COMPARISON_GREATER_THAN"
      threshold_value = 20 # Higher threshold for staging

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
    google_monitoring_notification_channel.staging_email.name
  ]

  alert_strategy {
    auto_close = "3600s"
  }
}

# Log-based metric for application errors in staging
resource "google_logging_metric" "staging_application_errors" {
  name   = "staging_application_errors"
  filter = "resource.type=\"cloud_run_revision\" AND (severity=\"ERROR\" OR jsonPayload.level=\"error\")"

  metric_descriptor {
    metric_kind  = "COUNTER"
    value_type   = "INT64"
    display_name = "Staging Application Errors"
  }

  label_extractors = {
    service_name = "EXTRACT(resource.labels.service_name)"
  }
}

# Alerting Policy for Application Errors (higher threshold for staging)
resource "google_monitoring_alert_policy" "staging_application_errors" {
  display_name = "Staging Application Error Rate"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "High application error rate"

    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/staging_application_errors\""
      duration        = "600s"
      comparison      = "COMPARISON_GREATER_THAN"
      threshold_value = 10 # Higher threshold for staging

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
    google_monitoring_notification_channel.staging_email.name
  ]

  alert_strategy {
    auto_close = "3600s"
  }

  documentation {
    content = "High application error rate detected in staging environment. Check application logs for details."
  }

  depends_on = [google_logging_metric.staging_application_errors]
}