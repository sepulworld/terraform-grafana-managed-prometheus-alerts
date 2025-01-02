resource "grafana_rule_group" "k8s_container_resource_limits" {
  name             = "k8s_container_resource_limits"
  folder_uid       = grafana_folder.prometheus_alerts.uid
  interval_seconds = var.alert_interval_seconds

  # Rule 1: Pod Memory Limits
  rule {
    name      = "ClusterNamespacePodMemoryActiveLimits"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "kube_pod_container_resource_limits{resource=\"memory\",job=\"kube-state-metrics\"} * on (namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (kube_pod_status_phase{phase=~\"Pending|Running\"} == 1)",
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

    annotations = {
      description = "Active memory resource limits by cluster, namespace, and pod."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # Rule 2: Namespace Memory Limits Sum
  rule {
    name      = "NamespaceMemoryLimitsSum"
    condition = "C"

    data {
      ref_id         = "B"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "sum by (namespace, cluster) (sum by (namespace, pod, cluster) (max by (namespace, pod, container, cluster) (kube_pod_container_resource_limits{resource=\"memory\",job=\"kube-state-metrics\"}) * on (namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (kube_pod_status_phase{phase=~\"Pending|Running\"} == 1)))",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "B"
      })

      relative_time_range {
        from = 300
        to   = 0
      }
    }

    annotations = {
      description = "Sum of memory resource limits by namespace and cluster."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # Rule 3: Pod CPU Limits
  rule {
    name      = "ClusterNamespacePodCPUActiveLimits"
    condition = "C"

    data {
      ref_id         = "C"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "kube_pod_container_resource_limits{resource=\"cpu\",job=\"kube-state-metrics\"} * on (namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (kube_pod_status_phase{phase=~\"Pending|Running\"} == 1)",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "C"
      })

      relative_time_range {
        from = 300
        to   = 0
      }
    }

    annotations = {
      description = "Active CPU resource limits by cluster, namespace, and pod."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # Rule 1: Relabel DaemonSet Workloads
  rule {
    name      = "NamespaceWorkloadPodDaemonSetRelabel"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "max by (cluster, namespace, workload, pod) (label_replace(kube_pod_owner{job=\"kube-state-metrics\", owner_kind=\"DaemonSet\"}, \"workload\", \"$1\", \"owner_name\", \"(.*)\"))",
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

    annotations = {
      description = "Relabel pods owned by DaemonSets to include the workload label."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # Rule 2: Relabel StatefulSet Workloads
  rule {
    name      = "NamespaceWorkloadPodStatefulSetRelabel"
    condition = "B"

    data {
      ref_id         = "B"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "max by (cluster, namespace, workload, pod) (label_replace(kube_pod_owner{job=\"kube-state-metrics\", owner_kind=\"StatefulSet\"}, \"workload\", \"$1\", \"owner_name\", \"(.*)\"))",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "B"
      })

      relative_time_range {
        from = 300
        to   = 0
      }
    }

    annotations = {
      description = "Relabel pods owned by StatefulSets to include the workload label."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # Rule 3: Relabel Job Workloads
  rule {
    name      = "NamespaceWorkloadPodJobRelabel"
    condition = "C"

    data {
      ref_id         = "C"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "max by (cluster, namespace, workload, pod) (label_replace(kube_pod_owner{job=\"kube-state-metrics\", owner_kind=\"Job\"}, \"workload\", \"$1\", \"owner_name\", \"(.*)\"))",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "C"
      })

      relative_time_range {
        from = 300
        to   = 0
      }
    }

    annotations = {
      description = "Relabel pods owned by Jobs to include the workload label."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
    }
  }
}