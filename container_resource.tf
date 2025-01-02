resource "grafana_rule_group" "k8s_container_resource" {
  name             = "k8s_container_resource"
  folder_uid       = grafana_folder.prometheus_alerts.uid
  interval_seconds = var.alert_interval_seconds

  # Rule 1: Memory Requests by Pod
  rule {
    name      = "ClusterNamespacePodMemoryActiveRequests"
    condition = "C"

    # Prometheus Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "kube_pod_container_resource_requests{resource=\"memory\",job=\"kube-state-metrics\"} * on (namespace, pod, cluster) group_left() max by (namespace, pod, cluster) ((kube_pod_status_phase{phase=~\"Pending|Running\"} == 1))",
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
      description = "Memory resource requests by namespace and pod."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
    }
  }

    # Rule 1: Namespace Memory Requests Sum
  rule {
    name      = "NamespaceMemoryRequestsSum"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "sum by (namespace, cluster) (sum by (namespace, pod, cluster) (max by (namespace, pod, container, cluster) (kube_pod_container_resource_requests{resource=\"memory\",job=\"kube-state-metrics\"}) * on (namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (kube_pod_status_phase{phase=~\"Pending|Running\"} == 1)))",
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
      description = "Memory resource requests sum by namespace and cluster."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # Rule 2: Pod CPU Requests
  rule {
    name      = "ClusterNamespacePodCPURequests"
    condition = "C"

    data {
      ref_id         = "B"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "kube_pod_container_resource_requests{resource=\"cpu\",job=\"kube-state-metrics\"} * on (namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (kube_pod_status_phase{phase=~\"Pending|Running\"} == 1)",
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
      description = "CPU resource requests by namespace and pod."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # Rule 3: Namespace CPU Requests Sum
  rule {
    name      = "NamespaceCPURequestsSum"
    condition = "C"

    data {
      ref_id         = "C"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "sum by (namespace, cluster) (sum by (namespace, pod, cluster) (max by (namespace, pod, container, cluster) (kube_pod_container_resource_requests{resource=\"cpu\",job=\"kube-state-metrics\"}) * on (namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (kube_pod_status_phase{phase=~\"Pending|Running\"} == 1)))",
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
      description = "CPU resource requests sum by namespace and cluster."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
    }
  }

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

  rule {
    name      = "NamespaceCPULimitsSum"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "sum by (namespace, cluster) (sum by (namespace, pod, cluster) (max by (namespace, pod, container, cluster) (kube_pod_container_resource_limits{resource=\"cpu\",job=\"kube-state-metrics\"}) * on (namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (kube_pod_status_phase{phase=~\"Pending|Running\"} == 1)))",
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
      description = "Sum of CPU resource limits by namespace and cluster."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
    }
  }
}