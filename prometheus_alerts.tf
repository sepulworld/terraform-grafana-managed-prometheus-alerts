resource "grafana_rule_group" "prometheus_alerts" {
  count            = var.prometheus_alerts_enabled ? 1 : 0
  name             = "prometheus"
  folder_uid       = grafana_folder.prometheus_alerts.uid
  interval_seconds = var.alert_interval_seconds

  rule {
    name      = "PrometheusBadConfig"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "max_over_time(prometheus_config_last_reload_successful{job=\"prometheus-kube-prometheus-prometheus\",namespace=\"${var.prometheus_namespace}\"}[5m]) == 0",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A",
        "instant"       = true
      })

      relative_time_range {
        from = 300 # Last 5 minutes
        to   = 0
      }
    }

    # Alert Settings
    annotations = {
      description = "Prometheus {{$labels.namespace}}/{{$labels.pod}} has failed to reload its configuration."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusbadconfig"
      summary     = "Failed Prometheus configuration reload."
    }

    labels = {
      severity = "critical"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"

    # Notification Settings
    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "pod"]
      mute_timings  = var.notification_settings.mute_timings
    }

    # Alert Timing
    for = "10m"
  }
    rule {
    name      = "PrometheusSDRefreshFailure"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "increase(prometheus_sd_refresh_failures_total{job=\"prometheus-kube-prometheus-prometheus\",namespace=\"monitoring\"}[10m]) > 0",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A",
        "instant"       = true
      })

      relative_time_range {
        from = 600 # Last 10 minutes
        to   = 0
      }
    }

    # Alert Settings
    annotations = {
      description = "Prometheus {{$labels.namespace}}/{{$labels.pod}} has failed to refresh SD with mechanism {{$labels.mechanism}}."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheussdrefreshfailure"
      summary     = "Failed Prometheus SD refresh."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"

    # Notification Settings
    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "pod", "mechanism"]
      mute_timings  = var.notification_settings.mute_timings
    }

    for = "20m"
  }

    rule {
    name      = "PrometheusKubernetesListWatchFailures"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "increase(prometheus_sd_kubernetes_failures_total{job=\"prometheus-kube-prometheus-prometheus\",namespace=\"monitoring\"}[5m]) > 0",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A",
        "instant"       = true
      })

      relative_time_range {
        from = 300 # Last 5 minutes
        to   = 0
      }
    }

    # Alert Settings
    annotations = {
      description = "Kubernetes service discovery of Prometheus {{$labels.namespace}}/{{$labels.pod}} is experiencing {{ printf \"%.0f\" $value }} failures with LIST/WATCH requests to the Kubernetes API in the last 5 minutes."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheuskuberneteslistwatchfailures"
      summary     = "Requests in Kubernetes SD are failing."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"

    for = "15m" 

    # Notification Settings
    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "pod"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

    rule {
    name      = "PrometheusNotificationQueueRunningFull"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(
  predict_linear(prometheus_notifications_queue_length{job="prometheus-kube-prometheus-prometheus",namespace="monitoring"}[5m], 60 * 30)
>
  min_over_time(prometheus_notifications_queue_capacity{job="prometheus-kube-prometheus-prometheus",namespace="monitoring"}[5m])
)
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A",
        "instant"       = true
      })

      relative_time_range {
        from = 300 # Last 5 minutes
        to   = 0
      }
    }

    # Alert Settings
    annotations = {
      description = "Alert notification queue of Prometheus {{$labels.namespace}}/{{$labels.pod}} is running full."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusnotificationqueuerunningfull"
      summary     = "Prometheus alert notification queue predicted to run full in less than 30m."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"

    for = "15m" # Ensuring the alert fires only after 15 minutes of sustained condition

    # Notification Settings
    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "pod"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }
    rule {
    name      = "PrometheusErrorSendingAlertsToSomeAlertmanagers"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(
  rate(prometheus_notifications_errors_total{job="prometheus-kube-prometheus-prometheus",namespace="monitoring"}[5m])
/
  rate(prometheus_notifications_sent_total{job="prometheus-kube-prometheus-prometheus",namespace="monitoring"}[5m])
)
* 100 > 1
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A",
        "instant"       = true
      })

      relative_time_range {
        from = 300 # Last 5 minutes
        to   = 0
      }
    }

    # Alert Settings
    annotations = {
      description = "{{ printf \"%.1f\" $value }}% errors while sending alerts from Prometheus {{$labels.namespace}}/{{$labels.pod}} to Alertmanager {{$labels.alertmanager}}."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheuserrorsendingalertstosomealertmanagers"
      summary     = "Prometheus has encountered more than 1% errors sending alerts to a specific Alertmanager."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"

    for = "15m" 

    # Notification Settings
    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "pod", "alertmanager"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

    rule {
    name      = "PrometheusNotConnectedToAlertmanagers"
    condition = "C"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
max_over_time(prometheus_notifications_alertmanagers_discovered{job="prometheus-kube-prometheus-prometheus",namespace="monitoring"}[5m]) < 1
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })
      relative_time_range {
        from = 300 # Query range: last 300 seconds
        to   = 0   # Current time
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
              "type"   = "lt",
              "params" = [1]
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
        from = 300 # Query range: last 300 seconds
        to   = 0   # Current time
      }
    }

    annotations = {
      description = "Prometheus is not connected to any Alertmanagers in the specified namespace and pod."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusnotconnectedtoalertmanagers"
      summary     = "Prometheus is not connected to any Alertmanagers."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "pod"]
      mute_timings  = var.notification_settings.mute_timings
    }

    # Alert Timing
    for = "10m"
  }

    rule {
    name      = "PrometheusTSDBReloadsFailing"
    condition = "C"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
increase(prometheus_tsdb_reloads_failures_total{job="prometheus-kube-prometheus-prometheus",namespace="monitoring"}[3h]) > 0
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })
      relative_time_range {
        from = 10800 # 3 hours in seconds
        to   = 0     # Current time
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
        from = 10800 # 3 hours in seconds
        to   = 0     # Current time
      }
    }

    annotations = {
      description = "Prometheus has detected reload failures in the last 3 hours for the specified namespace and pod."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheustsdbreloadsfailing"
      summary     = "Prometheus has issues reloading blocks from disk."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "pod"]
      mute_timings  = var.notification_settings.mute_timings
    }

    # Alert Timing
    for = "4h"
  }

    rule {
    name      = "PrometheusTSDBCompactionsFailing"
    condition = "C"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
increase(prometheus_tsdb_compactions_failed_total{job="prometheus-kube-prometheus-prometheus",namespace="monitoring"}[3h]) > 0
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })
      relative_time_range {
        from = 10800 # 3 hours in seconds
        to   = 0     # Current time
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
        from = 10800 # 3 hours in seconds
        to   = 0     # Current time
      }
    }

    annotations = {
      description = "Prometheus has detected compaction failures in the last 3 hours for the specified namespace and pod."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheustsdbcompactionsfailing"
      summary     = "Prometheus has issues compacting blocks."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "pod"]
      mute_timings  = var.notification_settings.mute_timings
    }

    # Alert Timing
    for = "4h"
  }

    rule {
    name      = "PrometheusNotIngestingSamples"
    condition = "C"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(
  sum without(type) (rate(prometheus_tsdb_head_samples_appended_total{job="prometheus-kube-prometheus-prometheus",namespace="monitoring"}[5m])) <= 0
and
  (
    sum without(scrape_job) (prometheus_target_metadata_cache_entries{job="prometheus-kube-prometheus-prometheus",namespace="monitoring"}) > 0
  or
    sum without(rule_group) (prometheus_rule_group_rules{job="prometheus-kube-prometheus-prometheus",namespace="monitoring"}) > 0
  )
)
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })
      relative_time_range {
        from = 300 # 5 minutes
        to   = 0   # Current time
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
        from = 300 # 5 minutes
        to   = 0   # Current time
      }
    }

    annotations = {
      description = "Prometheus is not ingesting samples for the specified namespace and pod."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusnotingestingsamples"
      summary     = "Prometheus is not ingesting samples."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "pod"]
      mute_timings  = var.notification_settings.mute_timings
    }

    # Alert Timing
    for = "10m"
  }

    rule {
    name      = "PrometheusDuplicateTimestamps"
    condition = "C"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
rate(prometheus_target_scrapes_sample_duplicate_timestamp_total{job="prometheus-kube-prometheus-prometheus",namespace="monitoring"}[5m]) > 0
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })
      relative_time_range {
        from = 300 # 5 minutes
        to   = 0   # Current time
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
        from = 300 # 5 minutes
        to   = 0   # Current time
      }
    }

    annotations = {
      description = "Prometheus is dropping samples with duplicate timestamps for the specified namespace and pod."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusduplicatetimestamps"
      summary     = "Prometheus is dropping samples with duplicate timestamps."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "pod"]
      mute_timings  = var.notification_settings.mute_timings
    }

    # Alert Timing
    for = "10m"
  }

    rule {
    name      = "PrometheusOutOfOrderTimestamps"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "rate(prometheus_target_scrapes_sample_out_of_order_total{job=\"prometheus-kube-prometheus-prometheus\",namespace=\"monitoring\"}[5m]) > 0",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })
      relative_time_range {
        from = 300 # 5 minutes
        to   = 0
      }
    }

    annotations = {
      summary     = "Prometheus is dropping samples with timestamps arriving out of order."
      description = "Prometheus {{$labels.namespace}}/{{$labels.pod}} is dropping {{ printf \"%.4g\" $value }} samples/s with timestamps arriving out of order."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusoutofordertimestamps"
    }

    labels = {
      severity = "warning"
    }

    for = "10m"
  }

    rule {
    name      = "PrometheusRemoteStorageFailures"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(
  (rate(prometheus_remote_storage_failed_samples_total{job="prometheus-kube-prometheus-prometheus",namespace="monitoring"}[5m]) or rate(prometheus_remote_storage_samples_failed_total{job="prometheus-kube-prometheus-prometheus",namespace="monitoring"}[5m]))
/
  (
    (rate(prometheus_remote_storage_failed_samples_total{job="prometheus-kube-prometheus-prometheus",namespace="monitoring"}[5m]) or rate(prometheus_remote_storage_samples_failed_total{job="prometheus-kube-prometheus-prometheus",namespace="monitoring"}[5m]))
  +
    (rate(prometheus_remote_storage_succeeded_samples_total{job="prometheus-kube-prometheus-prometheus",namespace="monitoring"}[5m]) or rate(prometheus_remote_storage_samples_total{job="prometheus-kube-prometheus-prometheus",namespace="monitoring"}[5m]))
  )
)
* 100
> 1
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })
      relative_time_range {
        from = 900 # 15 minutes
        to   = 0
      }
    }

    annotations = {
      summary     = "Prometheus is failing to send samples to remote storage."
      description = "Prometheus {{$labels.namespace}}/{{$labels.pod}} failed to send {{ printf \"%.1f\" $value }}% of the samples to {{ $labels.remote_name}}:{{ $labels.url }}"
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/prometheus/prometheusremotestoragefailures"
    }

    labels = {
      severity = "critical"
    }

    for = "15m"
  }
}
