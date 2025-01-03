resource "grafana_rule_group" "kube_prometheus_general_rules" {
  count            = var.prometheus_general_rules_enabled ? 1 : 0
  name             = "kube_prometheus_general_rules"
  folder_uid       = grafana_folder.prometheus_alerts.uid
  interval_seconds = var.alert_interval_seconds

  # Rule for count:up1
  rule {
    name      = "CountUp1RecordingRule"
    condition = "A" # Reference to the query node

    # Recording Rule
    record {
      from   = "A" # Refers to the data query
      metric = "count:up1"
    }

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "count without(instance, pod, node) (up == 1)",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })
      relative_time_range {
        from = 300 # Query range: last 300 seconds
        to   = 0   # Current time
      }
    }

    annotations = {
      description = "Counts the number of targets that are up."
    }

    labels = {
      severity = "info"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "pod"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # Rule for count:up0
  rule {
    name      = "CountUp0RecordingRule"
    condition = "A" # Reference to the query node

    # Recording Rule
    record {
      from   = "A" # Refers to the data query
      metric = "count:up0"
    }

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "count without(instance, pod, node) (up == 0)",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })
      relative_time_range {
        from = 300 # Query range: last 300 seconds
        to   = 0   # Current time
      }
    }

    annotations = {
      description = "Counts the number of targets that are down."
    }

    labels = {
      severity = "info"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "pod"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }
}
