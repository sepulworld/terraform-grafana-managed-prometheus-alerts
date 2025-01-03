resource "grafana_rule_group" "kube_prometheus_general_alerts" {
  name             = "kube_prometheus_general_alerts"
  folder_uid       = grafana_folder.prometheus_alerts.uid
  interval_seconds = var.alert_interval_seconds

  # Alert for count:up0 (Targets down)
  rule {
    name      = "AlertCountUp0"
    condition = "C"

    # Query to check for count:up0 (Targets down)
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "count:up0 > 0", # Alert if any target is down
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })
      relative_time_range {
        from = 300 # Query range: last 5 minutes
        to   = 0   # Current time
      }
    }

    # Alert threshold
    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        "conditions" = [
          {
            "evaluator" = {
              "type"   = "gt",
              "params" = [0]
            },
            "operator" = {
              "type" = "and"
            },
            "query"   = { "params" = ["A"] },
            "reducer" = { "type" = "last" },
            "type"    = "query"
          }
        ],
        "datasource"  = { "type" = "__expr__", "uid" = "__expr__" },
        "expression"  = "A",
        "intervalMs"  = 1000,
        "maxDataPoints" = 43200,
        "refId"       = "C",
        "type"        = "threshold"
      })
      relative_time_range {
        from = 300
        to   = 0
      }
    }

    annotations = {
      description = "Alert for down targets. Some targets are not reachable."
    }

    labels = {
      severity = "critical"
    }

    no_data_state  = "Alerting"
    exec_err_state = "Alerting"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # Alert for count:up1 (Targets up)
  rule {
    name      = "AlertCountUp1"
    condition = "C"

    # Query to check for count:up1 (Targets up)
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "count:up1 == 0", # Alert if no targets are up
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })
      relative_time_range {
        from = 300 # Query range: last 5 minutes
        to   = 0   # Current time
      }
    }

    # Alert threshold
    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = jsonencode({
        "conditions" = [
          {
            "evaluator" = {
              "type"   = "eq",
              "params" = [0]
            },
            "operator" = {
              "type" = "and"
            },
            "query"   = { "params" = ["A"] },
            "reducer" = { "type" = "last" },
            "type"    = "query"
          }
        ],
        "datasource"  = { "type" = "__expr__", "uid" = "__expr__" },
        "expression"  = "A",
        "intervalMs"  = 1000,
        "maxDataPoints" = 43200,
        "refId"       = "C",
        "type"        = "threshold"
      })
      relative_time_range {
        from = 300
        to   = 0
      }
    }

    annotations = {
      description = "Alert for no reachable targets. All targets are down."
    }

    labels = {
      severity = "critical"
    }

    no_data_state  = "Alerting"
    exec_err_state = "Alerting"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
    }
  }
}
