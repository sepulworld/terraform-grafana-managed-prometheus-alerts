resource "grafana_rule_group" "kube_prometheus_general_rules" {
  name             = "kube_prometheus_general_rules"
  folder_uid       = grafana_folder.prometheus_alerts.uid
  interval_seconds = var.alert_interval_seconds

  rule {
    name      = "CountUp1"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
count without(instance, pod, node) (up == 1)
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
      description = "Counts the number of targets that are up."
    }

    labels = {
      record = "count:up1"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
  }

  rule {
    name      = "CountUp0"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
count without(instance, pod, node) (up == 0)
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
      description = "Counts the number of targets that are down."
    }

    labels = {
      record = "count:up0"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
  }
}
