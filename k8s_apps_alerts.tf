resource "grafana_rule_group" "kubernetes_apps" {
  count            = var.kubernetes_apps_alerts_enabled ? 1 : 0
  name             = "kubernetes_apps"
  folder_uid       = grafana_folder.prometheus_alerts.uid
  interval_seconds = var.alert_interval_seconds

  # KubePodCrashLooping Alert
  rule {
    name      = "KubePodCrashLooping"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
max_over_time(kube_pod_container_status_waiting_reason{reason="CrashLoopBackOff", job="kube-state-metrics", namespace=~".*"}[5m]) >= 1
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })
      relative_time_range {
        from = 300 # Last 5 minutes
        to   = 0
      }
    }

    annotations = {
      description = "Pod {{ $labels.namespace }}/{{ $labels.pod }} ({{ $labels.container }}) is in waiting state (reason: 'CrashLoopBackOff')."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubepodcrashlooping"
      summary     = "Pod is crash looping."
    }

    labels = {
      severity = "warning"
    }

    for = "15m"
   

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "pod", "container"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # KubePodNotReady Alert
  rule {
    name      = "KubePodNotReady"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
sum by (namespace, pod, cluster) (
  max by (namespace, pod, cluster) (
    kube_pod_status_phase{job="kube-state-metrics", namespace=~".*", phase=~"Pending|Unknown|Failed"}
  ) * on (namespace, pod, cluster) group_left(owner_kind) topk by (namespace, pod, cluster) (
    1, max by (namespace, pod, owner_kind, cluster) (kube_pod_owner{owner_kind!="Job"})
  )
) > 0
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })
      relative_time_range {
        from = 300 # Last 5 minutes
        to   = 0
      }
    }

    annotations = {
      description = "Pod {{ $labels.namespace }}/{{ $labels.pod }} has been in a non-ready state for longer than 15 minutes."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubepodnotready"
      summary     = "Pod has been in a non-ready state for more than 15 minutes."
    }

    labels = {
      severity = "warning"
    }

    for = "15m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "pod"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }
}
