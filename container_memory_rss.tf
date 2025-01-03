resource "grafana_rule_group" "k8s_container_memory_rss" {
  count            = var.container_memory_rss_rules_enabled ? 1 : 0
  name             = "k8s_container_memory_rss"
  folder_uid       = grafana_folder.prometheus_alerts.uid
  interval_seconds = var.alert_interval_seconds

  rule {
    name      = "ContainerMemoryRSS"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "container_memory_rss{job=\"kubelet\", metrics_path=\"/metrics/cadvisor\", image!=\"\"} * on (cluster, namespace, pod) group_left(node) topk by (cluster, namespace, pod) (1, max by (cluster, namespace, pod, node) (kube_pod_info{node!=\"\"}))",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 300
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
        from = 300
        to   = 0
      }
    }

    annotations = {
      description = "Record container memory RSS utilization by cluster, namespace, and pod."
    }

    labels = {
      severity = "info" # Adjust as needed
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
