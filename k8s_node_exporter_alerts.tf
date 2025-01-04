resource "grafana_rule_group" "node_exporter_alerts"  {
  count           = var.node_exporter_alerts_enabled ? 1 : 0
  name             = "node_filesystem_space_filling_up"
  folder_uid       = grafana_folder.prometheus_alerts.uid
  interval_seconds = var.alert_interval_seconds

  # Alert: Filesystem predicted to run out of space within 24 hours
  rule {
    name      = "NodeFilesystemSpaceFillingUp24h"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(
  node_filesystem_avail_bytes{job="node-exporter",fstype!="",mountpoint!=""} / node_filesystem_size_bytes{job="node-exporter",fstype!="",mountpoint!=""} * 100 < 15
and
  predict_linear(node_filesystem_avail_bytes{job="node-exporter",fstype!="",mountpoint!=""}[6h], 24*60*60) < 0
and
  node_filesystem_readonly{job="node-exporter",fstype!="",mountpoint!=""} == 0
)
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })
      relative_time_range {
        from = 3600 # Last 1 hour
        to   = 0
      }
    }

    annotations = {
      description = "Filesystem on {{ $labels.device }}, mounted on {{ $labels.mountpoint }}, at {{ $labels.instance }} has only {{ printf \"%.2f\" $value }}% available space left and is filling up."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodefilesystemspacefillingup"
      summary     = "Filesystem is predicted to run out of space within the next 24 hours."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for            = "1h"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["device", "mountpoint", "instance"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # Alert: Filesystem predicted to run out of space within 4 hours
  rule {
    name      = "NodeFilesystemSpaceFillingUp4h"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(
  node_filesystem_avail_bytes{job="node-exporter",fstype!="",mountpoint!=""} / node_filesystem_size_bytes{job="node-exporter",fstype!="",mountpoint!=""} * 100 < 10
and
  predict_linear(node_filesystem_avail_bytes{job="node-exporter",fstype!="",mountpoint!=""}[6h], 4*60*60) < 0
and
  node_filesystem_readonly{job="node-exporter",fstype!="",mountpoint!=""} == 0
)
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })
      relative_time_range {
        from = 3600 # Last 1 hour
        to   = 0
      }
    }

    annotations = {
      description = "Filesystem on {{ $labels.device }}, mounted on {{ $labels.mountpoint }}, at {{ $labels.instance }} has only {{ printf \"%.2f\" $value }}% available space left and is filling up fast."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodefilesystemspacefillingup"
      summary     = "Filesystem is predicted to run out of space within the next 4 hours."
    }

    labels = {
      severity = "critical"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for            = "1h"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["device", "mountpoint", "instance"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }
  rule {
    name      = "NodeFilesystemAlmostOutOfSpace5Percent"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(
  node_filesystem_avail_bytes{job="node-exporter",fstype!="",mountpoint!=""} / node_filesystem_size_bytes{job="node-exporter",fstype!="",mountpoint!=""} * 100 < 5
and
  node_filesystem_readonly{job="node-exporter",fstype!="",mountpoint!=""} == 0
)
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })
      relative_time_range {
        from = 1800 # Last 30 minutes
        to   = 0
      }
    }

    annotations = {
      description = "Filesystem on {{ $labels.device }}, mounted on {{ $labels.mountpoint }}, at {{ $labels.instance }} has only {{ printf \"%.2f\" $value }}% available space left."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodefilesystemalmostoutofspace"
      summary     = "Filesystem has less than 5% space left."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for            = "30m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["device", "mountpoint", "instance"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # Alert: Filesystem has less than 3% space left
  rule {
    name      = "NodeFilesystemAlmostOutOfSpace3Percent"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(
  node_filesystem_avail_bytes{job="node-exporter",fstype!="",mountpoint!=""} / node_filesystem_size_bytes{job="node-exporter",fstype!="",mountpoint!=""} * 100 < 3
and
  node_filesystem_readonly{job="node-exporter",fstype!="",mountpoint!=""} == 0
)
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })
      relative_time_range {
        from = 1800 # Last 30 minutes
        to   = 0
      }
    }

    annotations = {
      description = "Filesystem on {{ $labels.device }}, mounted on {{ $labels.mountpoint }}, at {{ $labels.instance }} has only {{ printf \"%.2f\" $value }}% available space left."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodefilesystemalmostoutofspace"
      summary     = "Filesystem has less than 3% space left."
    }

    labels = {
      severity = "critical"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for            = "30m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["device", "mountpoint", "instance"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }
}
