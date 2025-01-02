resource "grafana_rule_group" "config_reloader_rules" {
  org_id           = var.grafana_org_id
  folder_uid       = grafana_folder.prometheus_alerts.uid
  name             = "Config Reloaders"
  interval_seconds = var.alert_interval_seconds

  rule {
    name      = "ConfigReloaderSidecarErrors"
    condition = "C"

    # Prometheus Query
    data {
      ref_id = "A"
      
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "max_over_time(reloader_last_reload_successful{namespace=~\\\".+\\\"}[5m]) == 0",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "instant": true,
  "refId": "A"
}
EOT

      relative_time_range {
        from = 300
        to   = 0
      }
    }

    # Threshold Condition
    data {
      ref_id = "C"
      datasource_uid = "__expr__"
      model = <<EOT
{
  "conditions": [
    {
      "evaluator": {
        "type": "gt",
        "params": [0]
      },
      "operator": {
        "type": "and"
      },
      "query": {
        "params": ["A"]
      },
      "reducer": {
        "type": "last"
      },
      "type": "query"
    }
  ],
  "datasource": {
    "type": "__expr__",
    "uid": "__expr__"
  },
  "expression": "A",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "refId": "C",
  "type": "threshold"
}
EOT

      relative_time_range {
        from = 300
        to   = 0
      }
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for            = "10m"
    annotations = {
      description = "Errors encountered while the {{$labels.pod}} config-reloader sidecar attempts to sync config in {{$labels.namespace}} namespace. Configuration for service running in {{$labels.pod}} may be stale and cannot be updated anymore."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/prometheus-operator/configreloadersidecarerrors"
      summary     = "config-reloader sidecar has not had a successful reload for 10m"
    }
    labels = {
      severity = "warning"
    }
  }
}
