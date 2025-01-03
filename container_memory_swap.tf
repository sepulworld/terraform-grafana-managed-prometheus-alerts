resource "grafana_rule_group" "k8s_container_memory_swap" {
  name             = "k8s.rules.container_memory_swap"
  folder_uid       = grafana_folder.prometheus_alerts.uid
  interval_seconds = var.alert_interval_seconds

  rule {
    name      = "ContainerMemorySwapRecordingRule"
    condition = "A" # Reference to the query node

    # Recording Rule
    record {
      from   = "A" # Refers to the data query
      metric = "node_namespace_pod_container:container_memory_swap"
    }

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "container_memory_swap{job=\"kubelet\", metrics_path=\"/metrics/cadvisor\", image!=\"\"} * on (cluster, namespace, pod) group_left(node) topk by (cluster, namespace, pod) (1, max by (cluster, namespace, pod, node) (kube_pod_info{node!=\"\"}))",
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
      description = "Record container memory swap usage by cluster, namespace, and pod."
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
