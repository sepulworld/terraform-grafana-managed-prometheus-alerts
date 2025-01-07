resource "grafana_rule_group" "kube_persistent_volume_alerts" {
  count            = var.kubernetes_storage_alerts_enabled ? 1 : 0
  name             = "kube_persistent_volume_alerts"
  folder_uid       = grafana_folder.prometheus_alerts.uid
  interval_seconds = var.alert_interval_seconds

  rule {
    name      = "KubePersistentVolumeFillingUpCritical"
    condition = "B"

    # Data Query A - Aggregation
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
avg by (namespace, persistentvolumeclaim) (
  kubelet_volume_stats_inodes_free{job="kubelet", namespace=~".*", metrics_path="/metrics"}
    /
  kubelet_volume_stats_inodes{job="kubelet", namespace=~".*", metrics_path="/metrics"}
)
and
avg by (namespace, persistentvolumeclaim) (
  kubelet_volume_stats_inodes_used{job="kubelet", namespace=~".*", metrics_path="/metrics"}
) > 0
unless on (namespace, persistentvolumeclaim)
kube_persistentvolumeclaim_access_mode{access_mode="ReadOnlyMany"} == 1
unless on (namespace, persistentvolumeclaim)
kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1

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

    # Threshold Query B - Apply Condition
    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 300 # Last 5 minutes
        to   = 0
      }
      model = jsonencode({
        "conditions" = [
          {
            "evaluator" = { "params" = [0.03], "type" = "lt" }, # Threshold: < 0.03
            "operator"  = { "type" = "and" },
            "query"     = { "params" = ["A"] }, # Reference Query A
            "reducer"   = { "params" = [], "type" = "last" },
            "type"      = "query"
          }
        ],
        "datasource"    = { "type" = "__expr__", "uid" = "__expr__" },
        "expression"    = "A",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "B",
        "type"          = "threshold"
      })
    }

    annotations = {
      description = "The PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} {{ with $labels.cluster -}} on Cluster {{ . }} {{- end }} is only {{ $value | humanizePercentage }} free."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubepersistentvolumefillingup"
      summary     = "PersistentVolume is filling up."
    }

    labels = {
      severity = "critical"
    }

    no_data_state = "OK"
    for           = "5m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "persistentvolumeclaim"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }


  rule {
    name      = "KubePersistentVolumeFillingUpWarning"
    condition = "B"

    # Data Query A - Aggregation
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
avg(
  kubelet_volume_stats_available_bytes{job="kubelet", namespace=~".*", metrics_path="/metrics"}
    /
  kubelet_volume_stats_capacity_bytes{job="kubelet", namespace=~".*", metrics_path="/metrics"}
)
and
avg(kubelet_volume_stats_used_bytes{job="kubelet", namespace=~".*", metrics_path="/metrics"}) > 0
and
avg(predict_linear(kubelet_volume_stats_available_bytes{job="kubelet", namespace=~".*", metrics_path="/metrics"}[6h], 4 * 24 * 3600)) < 0
unless on (cluster, namespace, persistentvolumeclaim)
kube_persistentvolumeclaim_access_mode{ access_mode="ReadOnlyMany"} == 1
unless on (cluster, namespace, persistentvolumeclaim)
kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1
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

    # Threshold Query B - Apply Condition
    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 300 # Last 5 minutes
        to   = 0
      }
      model = jsonencode({
        "conditions" = [
          {
            "evaluator" = { "params" = [0.15], "type" = "lt" }, # Threshold: < 0.15
            "operator"  = { "type" = "and" },
            "query"     = { "params" = ["A"] }, # Reference Query A
            "reducer"   = { "params" = [], "type" = "last" },
            "type"      = "query"
          }
        ],
        "datasource"    = { "type" = "__expr__", "uid" = "__expr__" },
        "expression"    = "A",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "B",
        "type"          = "threshold"
      })
    }

    annotations = {
      description = "Based on recent sampling, the PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} {{ with $labels.cluster -}} on Cluster {{ . }} {{- end }} is expected to fill up within four days. Currently {{ $value | humanizePercentage }} is available."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubepersistentvolumefillingup"
      summary     = "PersistentVolume is filling up."
    }

    labels = {
      severity = "warning"
    }

    no_data_state = "OK"
    for           = "1h"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "persistentvolumeclaim"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  rule {
    name      = "KubePersistentVolumeInodesFillingUpCritical"
    condition = "B"

    # Data Query A - Aggregation
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(
  kubelet_volume_stats_inodes_free{job="kubelet", namespace=~".*", metrics_path="/metrics"}
    /
  kubelet_volume_stats_inodes{job="kubelet", namespace=~".*", metrics_path="/metrics"}
)
and
kubelet_volume_stats_inodes_used{job="kubelet", namespace=~".*", metrics_path="/metrics"} > 0
unless on (cluster, namespace, persistentvolumeclaim)
kube_persistentvolumeclaim_access_mode{ access_mode="ReadOnlyMany"} == 1
unless on (cluster, namespace, persistentvolumeclaim)
kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1
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

    # Threshold Query B - Apply Condition
    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 300 # Last 5 minutes
        to   = 0
      }
      model = jsonencode({
        "conditions" = [
          {
            "evaluator" = { "params" = [0.03], "type" = "lt" }, # Threshold: < 0.03
            "operator"  = { "type" = "and" },
            "query"     = { "params" = ["A"] }, # Reference Query A
            "reducer"   = { "params" = [], "type" = "last" },
            "type"      = "query"
          }
        ],
        "datasource"    = { "type" = "__expr__", "uid" = "__expr__" },
        "expression"    = "A",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "B",
        "type"          = "threshold"
      })
    }

    annotations = {
      description = "The PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} {{ with $labels.cluster -}} on Cluster {{ . }} {{- end }} only has {{ $value | humanizePercentage }} free inodes."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubepersistentvolumeinodesfillingup"
      summary     = "PersistentVolumeInodes are filling up."
    }

    labels = {
      severity = "critical"
    }

    no_data_state = "OK"
    for           = "1m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "persistentvolumeclaim"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }


  rule {
    name      = "KubePersistentVolumeInodesFillingUpWarning"
    condition = "B"

    # Data Query A - Aggregation
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(
  kubelet_volume_stats_inodes_free{job="kubelet", namespace=~".*", metrics_path="/metrics"}
    /
  kubelet_volume_stats_inodes{job="kubelet", namespace=~".*", metrics_path="/metrics"}
)
and
kubelet_volume_stats_inodes_used{job="kubelet", namespace=~".*", metrics_path="/metrics"} > 0
and
predict_linear(kubelet_volume_stats_inodes_free{job="kubelet", namespace=~".*", metrics_path="/metrics"}[6h], 4 * 24 * 3600) < 0
unless on (cluster, namespace, persistentvolumeclaim)
kube_persistentvolumeclaim_access_mode{ access_mode="ReadOnlyMany"} == 1
unless on (cluster, namespace, persistentvolumeclaim)
kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1
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

    # Threshold Query B - Apply Condition
    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 300 # Last 5 minutes
        to   = 0
      }
      model = jsonencode({
        "conditions" = [
          {
            "evaluator" = { "params" = [0.15], "type" = "lt" }, # Threshold: < 0.15
            "operator"  = { "type" = "and" },
            "query"     = { "params" = ["A"] }, # Reference Query A
            "reducer"   = { "params" = [], "type" = "last" },
            "type"      = "query"
          }
        ],
        "datasource"    = { "type" = "__expr__", "uid" = "__expr__" },
        "expression"    = "A",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "B",
        "type"          = "threshold"
      })
    }

    annotations = {
      description = "Based on recent sampling, the PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} {{ with $labels.cluster -}} on Cluster {{ . }} {{- end }} is expected to run out of inodes within four days. Currently {{ $value | humanizePercentage }} of its inodes are free."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubepersistentvolumeinodesfillingup"
      summary     = "PersistentVolumeInodes are filling up."
    }

    labels = {
      severity = "warning"
    }

    no_data_state = "OK"
    for           = "1h"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "persistentvolumeclaim"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  rule {
    name      = "KubePersistentVolumeErrors"
    condition = "B"

    # Data Query A - Raw Metric Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
kube_persistentvolume_status_phase{phase=~"Failed|Pending",job="kube-state-metrics"} > 0
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

    # Threshold Query B - Apply Condition
    data {
      ref_id         = "B"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 300 # Last 5 minutes
        to   = 0
      }
      model = jsonencode({
        "conditions" = [
          {
            "evaluator" = { "params" = [0], "type" = "gt" }, # Threshold: > 0
            "operator"  = { "type" = "and" },
            "query"     = { "params" = ["A"] }, # Reference Query A
            "reducer"   = { "params" = [], "type" = "last" },
            "type"      = "query"
          }
        ],
        "datasource"    = { "type" = "__expr__", "uid" = "__expr__" },
        "expression"    = "A",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "B",
        "type"          = "threshold"
      })
    }

    annotations = {
      description = "The persistent volume {{ $labels.persistentvolume }} {{ with $labels.cluster -}} on Cluster {{ . }} {{- end }} has status {{ $labels.phase }}."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubepersistentvolumeerrors"
      summary     = "PersistentVolume is having issues with provisioning."
    }

    labels = {
      severity = "critical"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for            = "5m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["persistentvolume"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }
}