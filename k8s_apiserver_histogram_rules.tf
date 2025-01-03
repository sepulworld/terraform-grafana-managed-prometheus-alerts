resource "grafana_rule_group" "kube_apiserver_histogram_rules" {
  name             = "kube_apiserver_histogram_rules"
  folder_uid       = grafana_folder.prometheus_alerts.uid
  interval_seconds = var.alert_interval_seconds

  rule {
    name      = "ApiserverRequestHistogramQuantile_99thPercentile"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
histogram_quantile(0.99, sum by (cluster, le, resource) (rate(apiserver_request_sli_duration_seconds_bucket{job="apiserver",verb=~"LIST|GET",subresource!~"proxy|attach|log|exec|portforward"}[5m]))) > 0
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 300 # 5 minutes
        to   = 0
      }
    }

    annotations = {
      description = "99th percentile histogram quantile for API server request duration (read operations)."
    }

    labels = {
      quantile = "0.99"
      verb     = "read"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
group_by = var.notification_settings.group_by
    }
  }
    rule {
    name      = "ApiserverRequestHistogramQuantile_99thPercentile_Write"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
histogram_quantile(0.99, sum by (cluster, le, resource) (rate(apiserver_request_sli_duration_seconds_bucket{job="apiserver",verb=~"POST|PUT|PATCH|DELETE",subresource!~"proxy|attach|log|exec|portforward"}[5m]))) > 0
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 300 # 5 minutes
        to   = 0
      }
    }

    annotations = {
      description = "99th percentile histogram quantile for API server request duration (write operations)."
    }

    labels = {
      quantile = "0.99"
      verb     = "write"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
  }
}