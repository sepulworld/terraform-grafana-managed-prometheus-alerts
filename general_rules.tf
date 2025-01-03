resource "grafana_rule_group" "target_down_and_watchdog" {
  name             = "General Alerts"
  folder_uid       = "prometheus_alerts"
  interval_seconds = var.alert_interval_seconds

  # TargetDown Rule
  rule {
    name      = "TargetDown"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "100 * (count(up == 0) BY (cluster, job, namespace, service) / count(up) BY (cluster, job, namespace, service)) > 10",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 600
        to   = 0
      }
    }

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
        from = 600
        to   = 0
      }
    }

    annotations = {
      description = "{{ printf \"%.4g\" $value }}% of the {{ $labels.job }}/{{ $labels.service }} targets in {{ $labels.namespace }} namespace are down."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/general/targetdown"
      summary     = "One or more targets are unreachable."
    }
    labels = {
      severity = "warning"
    }
    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
    for            = "10m"
    no_data_state  = "OK"
    exec_err_state = "OK"
  }

  # Watchdog Rule
  rule {
    name      = "Watchdog"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "vector(1)",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 0
        to   = 0
      }
    }

    annotations = {
      description = <<EOT
This is an alert meant to ensure that the entire alerting pipeline is functional.
This alert is always firing, therefore it should always be firing in Alertmanager
and always fire against a receiver. There are integrations with various notification
mechanisms that send a notification when this alert is not firing. For example, the
"DeadMansSnitch" integration in PagerDuty.
EOT
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/general/watchdog"
      summary     = "An alert that should always be firing to certify that Alertmanager is working properly."
    }
    labels = {
      severity = "none"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
  }

    rule {
    name      = "InfoInhibitor"
    condition = "C"

    # Prometheus Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "ALERTS{severity=\"info\"} == 1 unless on (namespace) ALERTS{alertname!=\"InfoInhibitor\", severity=~\"warning|critical\", alertstate=\"firing\"} == 1",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 0
        to   = 0
      }
    }

    # Threshold Condition
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
        from = 0
        to   = 0
      }
    }

    # Alert annotations
    annotations = {
      description = <<EOT
This is an alert that is used to inhibit info alerts.
By themselves, the info-level alerts are sometimes very noisy, but they are relevant when combined with
other alerts.
This alert fires whenever there's a severity="info" alert, and stops firing when another alert with a
severity of 'warning' or 'critical' starts firing on the same namespace.
This alert should be routed to a null receiver and configured to inhibit alerts with severity="info".
EOT
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/general/infoinhibitor"
      summary     = "Info-level alert inhibition."
    }

    # Alert labels
    labels = {
      severity = "none"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
  }
}