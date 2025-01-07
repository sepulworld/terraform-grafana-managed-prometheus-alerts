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
sum by (namespace, pod) (
  max by (namespace, pod) (
    kube_pod_status_phase{job="kube-state-metrics", namespace=~".*", phase=~"Pending|Unknown|Failed"}
  ) * on (namespace, pod) group_left(owner_kind) topk by (namespace, pod) (
    1, max by (namespace, pod, owner_kind) (kube_pod_owner{owner_kind!="Job"})
  )
) > 0
EOT
      "intervalMs"    = 1000,
      "maxDataPoints" = 43200,
      "refId"         = "A"
    })
    relative_time_range {
      from = 900 # Last 5 minutes
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
        from = 900 # Last 5 minutes
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

    rule {
    name      = "KubeDeploymentRolloutStuck"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
kube_deployment_status_condition{condition="Progressing", status="false", job="kube-state-metrics", namespace=~".*"} != 0
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
      description = "Rollout of deployment {{ $labels.namespace }}/{{ $labels.deployment }} is not progressing for longer than 15 minutes."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubedeploymentrolloutstuck"
      summary     = "Deployment rollout is not progressing."
    }

    labels = {
      severity = "warning"
    }

    no_data_state = "OK"
    for           = "15m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "deployment"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # KubeStatefulSetReplicasMismatch Alert
  rule {
    name      = "KubeStatefulSetReplicasMismatch"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(
  kube_statefulset_status_replicas_ready{job="kube-state-metrics", namespace=~".*"} != kube_statefulset_status_replicas{job="kube-state-metrics", namespace=~".*"}
) and (
  changes(kube_statefulset_status_replicas_updated{job="kube-state-metrics", namespace=~".*"}[10m]) == 0
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
      description = "StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} has not matched the expected number of replicas for longer than 15 minutes."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubestatefulsetreplicasmismatch"
      summary     = "StatefulSet has not matched the expected number of replicas."
    }

    labels = {
      severity = "warning"
    }

    no_data_state = "OK"
    for           = "15m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "statefulset"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

    rule {
    name      = "KubeStatefulSetGenerationMismatch"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
kube_statefulset_status_observed_generation{job="kube-state-metrics", namespace=~".*"}
  !=
kube_statefulset_metadata_generation{job="kube-state-metrics", namespace=~".*"}
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
      description = "StatefulSet generation for {{ $labels.namespace }}/{{ $labels.statefulset }} does not match, this indicates that the StatefulSet has failed but has not been rolled back."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubestatefulsetgenerationmismatch"
      summary     = "StatefulSet generation mismatch due to possible roll-back"
    }

    labels = {
      severity = "warning"
    }

    no_data_state = "OK"
    for           = "15m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "statefulset"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # KubeStatefulSetUpdateNotRolledOut Alert
  rule {
    name      = "KubeStatefulSetUpdateNotRolledOut"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(
  max by (namespace, statefulset) (
    kube_statefulset_status_current_revision{job="kube-state-metrics", namespace=~".*"}
      unless
    kube_statefulset_status_update_revision{job="kube-state-metrics", namespace=~".*"}
  )
    *
  (
    kube_statefulset_replicas{job="kube-state-metrics", namespace=~".*"}
      !=
    kube_statefulset_status_replicas_updated{job="kube-state-metrics", namespace=~".*"}
  )
) and (
  changes(kube_statefulset_status_replicas_updated{job="kube-state-metrics", namespace=~".*"}[5m]) == 0
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
      description = "StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} update has not been rolled out."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubestatefulsetupdatenotrolledout"
      summary     = "StatefulSet update has not been rolled out."
    }

    labels = {
      severity = "warning"
    }

    no_data_state = "OK"
    for           = "15m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "statefulset"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }


  rule {
    name      = "KubeDaemonSetRolloutStuck"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(
  (
    kube_daemonset_status_current_number_scheduled{job="kube-state-metrics", namespace=~".*", instance=~".*"}
     !=
    kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics", namespace=~".*", instance=~".*"}
  ) or (
    kube_daemonset_status_number_misscheduled{job="kube-state-metrics", namespace=~".*", instance=~".*"}
     !=
    0
  ) or (
    kube_daemonset_status_updated_number_scheduled{job="kube-state-metrics", namespace=~".*", instance=~".*"}
     !=
    kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics", namespace=~".*"}
  ) or (
    kube_daemonset_status_number_available{job="kube-state-metrics", namespace=~".*", instance=~".*"}
     !=
    kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics", namespace=~".*"}
  )
) and (
  changes(kube_daemonset_status_updated_number_scheduled{job="kube-state-metrics", namespace=~".*"}[5m]) == 0
)
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })
      relative_time_range {
        from = 900 # Last 15 minutes
        to   = 0
      }
    }

    annotations = {
      description = "DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} has not finished or progressed for at least 15 minutes."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubedaemonsetrolloutstuck"
      summary     = "DaemonSet rollout is stuck."
    }

    labels = {
      severity = "warning"
    }

    no_data_state = "OK"
    for           = "15m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "daemonset"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  rule {
    name      = "Test"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = var.datasource_uid
      model          = "{\"editorMode\":\"code\",\"expr\":\"sum by (namespace, pod) (kube_pod_container_status_waiting_reason{job=\\\"kube-state-metrics\\\",\\n        namespace=~\\\".*\\\"}) > 0\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }
    data {
      ref_id = "B"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[\"B\"]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"reducer\":\"last\",\"refId\":\"B\",\"type\":\"reduce\"}"
    }
    data {
      ref_id = "C"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[\"C\"]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"B\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

  annotations = {
    description = "Container {{ $labels.container }} in pod {{ $labels.pod }} (namespace {{ $labels.namespace }}) has been in a waiting state for more than 1 hour."
    runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubecontainerwaiting"
    summary     = "Pod container waiting longer than 1 hour."
  }

  labels = {
    severity = "warning"
  }

  no_data_state = "OK"
  for           = "1h"

  notification_settings {
    contact_point = var.notification_settings.contact_point
    group_by      = ["namespace", "pod", "container"]
    mute_timings  = var.notification_settings.mute_timings
  }
}

    rule {
    name      = "KubeDaemonSetNotScheduled"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics", namespace=~".*"}
  -
kube_daemonset_status_current_number_scheduled{job="kube-state-metrics", namespace=~".*"} > 0
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })
      relative_time_range {
        from = 600 # Last 10 minutes
        to   = 0
      }
    }

    annotations = {
      description = "{{ $value }} Pods of DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} are not scheduled."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubedaemonsetnotscheduled"
      summary     = "DaemonSet pods are not scheduled."
    }

    labels = {
      severity = "warning"
    }

    no_data_state = "OK"
    for           = "10m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "daemonset"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # KubeDaemonSetMisScheduled Alert
  rule {
    name      = "KubeDaemonSetMisScheduled"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
kube_daemonset_status_number_misscheduled{job="kube-state-metrics", namespace=~".*"} > 0
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })
      relative_time_range {
        from = 900 # Last 15 minutes
        to   = 0
      }
    }

    annotations = {
      description = "{{ $value }} Pods of DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} are running where they are not supposed to run."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubedaemonsetmisscheduled"
      summary     = "DaemonSet pods are misscheduled."
    }

    labels = {
      severity = "warning"
    }

    no_data_state = "OK"
    for           = "15m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "daemonset"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

    rule {
    name      = "KubeJobNotCompleted"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
time() - max by (namespace, job_name, cluster) (
  kube_job_status_start_time{job="kube-state-metrics", namespace=~".*"}
  and
  kube_job_status_active{job="kube-state-metrics", namespace=~".*"} > 0
) > 43200
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })
      relative_time_range {
        from = 300
        to   = 0
      }
    }

    annotations = {
      description = "Job {{ $labels.namespace }}/{{ $labels.job_name }} is taking more than 12 hours to complete."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubejobnotcompleted"
      summary     = "Job did not complete in time."
    }

    labels = {
      severity = "warning"
    }

    no_data_state = "OK"
    for           = "0s"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "job_name"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # KubeJobFailed Alert
  rule {
    name      = "KubeJobFailed"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
kube_job_failed{job="kube-state-metrics", namespace=~".*"} > 0
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })
      relative_time_range {
        from = 900 # Last 15 minutes
        to   = 0
      }
    }

    annotations = {
      description = "Job {{ $labels.namespace }}/{{ $labels.job_name }} failed to complete. Removing failed job after investigation should clear this alert."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubejobfailed"
      summary     = "Job failed to complete."
    }

    labels = {
      severity = "warning"
    }

    no_data_state = "OK"
    for           = "15m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "job_name"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }
  rule {
    name      = "KubeHpaReplicasMismatch"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(
  kube_horizontalpodautoscaler_status_desired_replicas{job="kube-state-metrics", namespace=~".*"}
    !=
  kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics", namespace=~".*"}
)
  and
(
  kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics", namespace=~".*"}
    >
  kube_horizontalpodautoscaler_spec_min_replicas{job="kube-state-metrics", namespace=~".*"}
)
  and
(
  kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics", namespace=~".*"}
    <
  kube_horizontalpodautoscaler_spec_max_replicas{job="kube-state-metrics", namespace=~".*"}
)
  and
(
  changes(kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics", namespace=~".*"}[15m]) == 0
)
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })
      relative_time_range {
        from = 300
        to   = 0
      }
    }

    annotations = {
      description = "HPA {{ $labels.namespace }}/{{ $labels.horizontalpodautoscaler }} has not matched the desired number of replicas for longer than 15 minutes."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubehpareplicasmismatch"
      summary     = "HPA has not matched desired number of replicas."
    }

    labels = {
      severity = "warning"
    }

    no_data_state = "OK"
    for           = "15m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "horizontalpodautoscaler"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # KubeHpaMaxedOut Alert
  rule {
    name      = "KubeHpaMaxedOut"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
max(kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics", namespace=~".*"})
  ==
max(kube_horizontalpodautoscaler_spec_max_replicas{job="kube-state-metrics", namespace=~".*"})
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })
      relative_time_range {
        from = 900
        to   = 0
      }
    }

    annotations = {
      description = "HPA {{ $labels.namespace }}/{{ $labels.horizontalpodautoscaler }} has been running at max replicas for longer than 15 minutes."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubehpamaxedout"
      summary     = "HPA is running at max replicas."
    }

    labels = {
      severity = "warning"
    }

    no_data_state = "OK"
    for           = "15m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "horizontalpodautoscaler"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }
}