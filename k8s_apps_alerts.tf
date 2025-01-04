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

    no_data_state = "OK"
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

    no_data_state = "OK"
    for = "15m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "pod"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

    # KubeDeploymentGenerationMismatch Alert
  rule {
    name      = "KubeDeploymentGenerationMismatch"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
kube_deployment_status_observed_generation{job="kube-state-metrics", namespace=~".*"}
  !=
kube_deployment_metadata_generation{job="kube-state-metrics", namespace=~".*"}
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
      description = "Deployment generation for {{ $labels.namespace }}/{{ $labels.deployment }} does not match, this indicates that the Deployment has failed but has not been rolled back."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubedeploymentgenerationmismatch"
      summary     = "Deployment generation mismatch due to possible roll-back"
    }

    labels = {
      severity = "warning"
    }

    no_data_state = "OK"
    for = "15m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "deployment"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # KubeDeploymentReplicasMismatch Alert
  rule {
    name      = "KubeDeploymentReplicasMismatch"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(
  kube_deployment_spec_replicas{job="kube-state-metrics", namespace=~".*"}
    >
  kube_deployment_status_replicas_available{job="kube-state-metrics", namespace=~".*"}
) and (
  changes(kube_deployment_status_replicas_updated{job="kube-state-metrics", namespace=~".*"}[10m])
    ==
  0
)
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
      description = "Deployment {{ $labels.namespace }}/{{ $labels.deployment }} has not matched the expected number of replicas for longer than 15 minutes."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubedeploymentreplicasmismatch"
      summary     = "Deployment has not matched the expected number of replicas."
    }

    labels = {
      severity = "warning"
    }

    no_data_state = "OK"
    for = "15m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "deployment"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }
}
