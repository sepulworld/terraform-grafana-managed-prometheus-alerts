resource "grafana_rule_group" "node_exporter_alerts"  {
  count           = var.node_exporter_alerts_enabled ? 1 : 0
  name             = "node_exporter_alerts"
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

    # Alert: Filesystem predicted to run out of inodes within the next 24 hours
  rule {
    name      = "NodeFilesystemFilesFillingUpSlow"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(
  node_filesystem_files_free{job="node-exporter",fstype!="",mountpoint!=""} / node_filesystem_files{job="node-exporter",fstype!="",mountpoint!=""} * 100 < 40
and
  predict_linear(node_filesystem_files_free{job="node-exporter",fstype!="",mountpoint!=""}[6h], 24*60*60) < 0
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
      description = "Filesystem on {{ $labels.device }}, mounted on {{ $labels.mountpoint }}, at {{ $labels.instance }} has only {{ printf \"%.2f\" $value }}% available inodes left and is filling up."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodefilesystemfilesfillingup"
      summary     = "Filesystem is predicted to run out of inodes within the next 24 hours."
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

  # Alert: Filesystem predicted to run out of inodes within the next 4 hours
  rule {
    name      = "NodeFilesystemFilesFillingUpFast"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(
  node_filesystem_files_free{job="node-exporter",fstype!="",mountpoint!=""} / node_filesystem_files{job="node-exporter",fstype!="",mountpoint!=""} * 100 < 20
and
  predict_linear(node_filesystem_files_free{job="node-exporter",fstype!="",mountpoint!=""}[6h], 4*60*60) < 0
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
      description = "Filesystem on {{ $labels.device }}, mounted on {{ $labels.mountpoint }}, at {{ $labels.instance }} has only {{ printf \"%.2f\" $value }}% available inodes left and is filling up fast."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodefilesystemfilesfillingup"
      summary     = "Filesystem is predicted to run out of inodes within the next 4 hours."
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

    # Alert: Filesystem has less than 5% inodes left
  rule {
    name      = "NodeFilesystemAlmostOutOfFilesWarning"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(
  node_filesystem_files_free{job="node-exporter",fstype!="",mountpoint!=""} / node_filesystem_files{job="node-exporter",fstype!="",mountpoint!=""} * 100 < 5
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
      description = "Filesystem on {{ $labels.device }}, mounted on {{ $labels.mountpoint }}, at {{ $labels.instance }} has only {{ printf \"%.2f\" $value }}% available inodes left."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodefilesystemalmostoutoffiles"
      summary     = "Filesystem has less than 5% inodes left."
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

  # Alert: Filesystem has less than 3% inodes left
  rule {
    name      = "NodeFilesystemAlmostOutOfFilesCritical"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
(
  node_filesystem_files_free{job="node-exporter",fstype!="",mountpoint!=""} / node_filesystem_files{job="node-exporter",fstype!="",mountpoint!=""} * 100 < 3
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
      description = "Filesystem on {{ $labels.device }}, mounted on {{ $labels.mountpoint }}, at {{ $labels.instance }} has only {{ printf \"%.2f\" $value }}% available inodes left."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodefilesystemalmostoutoffiles"
      summary     = "Filesystem has less than 3% inodes left."
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

    # Alert: NodeNetworkReceiveErrs
  rule {
    name      = "NodeNetworkReceiveErrs"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
rate(node_network_receive_errs_total{job="node-exporter"}[2m]) / rate(node_network_receive_packets_total{job="node-exporter"}[2m]) > 0.01
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
      description = "{{ $labels.instance }} interface {{ $labels.device }} has encountered {{ printf \"%.0f\" $value }} receive errors in the last two minutes."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodenetworkreceiveerrs"
      summary     = "Network interface is reporting many receive errors."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for            = "1h"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["instance", "device"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

  # Alert: NodeNetworkTransmitErrs
  rule {
    name      = "NodeNetworkTransmitErrs"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
rate(node_network_transmit_errs_total{job="node-exporter"}[2m]) / rate(node_network_transmit_packets_total{job="node-exporter"}[2m]) > 0.01
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
      description = "{{ $labels.instance }} interface {{ $labels.device }} has encountered {{ printf \"%.0f\" $value }} transmit errors in the last two minutes."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodenetworktransmiterrs"
      summary     = "Network interface is reporting many transmit errors."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for            = "1h"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["instance", "device"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }

    rule {
    name      = "NodeHighNumberConntrackEntriesUsed"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "(node_nf_conntrack_entries{job=\"node-exporter\"} / node_nf_conntrack_entries_limit) > 0.75",
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
      description = "{{ $value | humanizePercentage }} of conntrack entries are used."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodehighnumberconntrackentriesused"
      summary     = "Number of conntrack are getting close to the limit."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
  }
    rule {
    name      = "NodeTextFileCollectorScrapeError"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "node_textfile_scrape_error{job=\"node-exporter\"} == 1",
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
      description = "Node Exporter text file collector on {{ $labels.instance }} failed to scrape."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodetextfilecollectorscrapeerror"
      summary     = "Node Exporter text file collector failed to scrape."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
  }

    rule {
    name      = "NodeClockNotSynchronising"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "min_over_time(node_timex_sync_status{job=\"node-exporter\"}[5m]) == 0 and node_timex_maxerror_seconds{job=\"node-exporter\"} >= 16",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })
      relative_time_range {
        from = 600
        to   = 0
      }
    }

    annotations = {
      description = "Clock at {{ $labels.instance }} is not synchronising. Ensure NTP is configured on this host."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodeclocknotsynchronising"
      summary     = "Clock not synchronising."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
  }

    rule {
    name      = "NodeClockSkewDetected"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "(node_timex_offset_seconds{job=\"node-exporter\"} > 0.05 and deriv(node_timex_offset_seconds{job=\"node-exporter\"}[5m]) >= 0) or (node_timex_offset_seconds{job=\"node-exporter\"} < -0.05 and deriv(node_timex_offset_seconds{job=\"node-exporter\"}[5m]) <= 0)",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })
      relative_time_range {
        from = 600
        to   = 0
      }
    }

    annotations = {
      description = "Clock at {{ $labels.instance }} is out of sync by more than 0.05s. Ensure NTP is configured correctly on this host."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodeclockskewdetected"
      summary     = "Clock skew detected."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
  }

    rule {
    name      = "NodeRAIDDegraded"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "node_md_disks_required{job=\"node-exporter\",device=~\"(/dev/)?(mmcblk.p.+|nvme.+|rbd.+|sd.+|vd.+|xvd.+|dm-.+|md.+|dasd.+)\"} - ignoring (state) (node_md_disks{state=\"active\",job=\"node-exporter\",device=~\"(/dev/)?(mmcblk.p.+|nvme.+|rbd.+|sd.+|vd.+|xvd.+|dm-.+|md.+|dasd.+)\"}) > 0",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })
      relative_time_range {
        from = 900
        to   = 0
      }
    }

    annotations = {
      description = "RAID array '{{ $labels.device }}' at {{ $labels.instance }} is in degraded state due to one or more disks failures. Number of spare drives is insufficient to fix issue automatically."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/noderaiddegraded"
      summary     = "RAID Array is degraded."
    }

    labels = {
      severity = "critical"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
  }

    rule {
    name      = "NodeRAIDDiskFailure"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "node_md_disks{state=\"failed\",job=\"node-exporter\",device=~\"(/dev/)?(mmcblk.p.+|nvme.+|rbd.+|sd.+|vd.+|xvd.+|dm-.+|md.+|dasd.+)\"} > 0",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })
      relative_time_range {
        from = 900
        to   = 0
      }
    }

    annotations = {
      description = "At least one device in RAID array at {{ $labels.instance }} failed. Array '{{ $labels.device }}' needs attention and possibly a disk swap."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/noderaiddiskfailure"
      summary     = "Failed device in RAID array."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
  }

    rule {
    name      = "NodeCPUHighUsageInfo"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "sum without(mode) (avg without (cpu) (rate(node_cpu_seconds_total{job=\"node-exporter\", mode!=\"idle\"}[2m]))) * 100 > 90",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })
      relative_time_range {
        from = 900
        to   = 0
      }
    }

    annotations = {
      description = "CPU usage at {{ $labels.instance }} has been above 90% for the last 15 minutes, is currently at {{ printf \"%.2f\" $value }}%."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodecpuhighusage"
      summary     = "High CPU usage."
    }

    labels = {
      severity = "info"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
  }

    rule {
    name      = "NodeSystemSaturationWarning"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "node_load1{job=\"node-exporter\"} / count without (cpu, mode) (node_cpu_seconds_total{job=\"node-exporter\", mode=\"idle\"}) > 5",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })
      relative_time_range {
        from = 900
        to   = 0
      }
    }

    annotations = {
      description = <<EOT
System load per core at {{ $labels.instance }} has been above 2 for the last 15 minutes, is currently at {{ printf "%.2f" $value }}.
This might indicate this instance resources saturation and can cause it becoming unresponsive.
EOT
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodesystemsaturation"
      summary     = "System saturated, load per core is very high."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
  }

   rule {
    name      = "NodeMemoryMajorPagesFaultsWarning"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "rate(node_vmstat_pgmajfault{job=\"node-exporter\"}[5m]) > 500",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })
      relative_time_range {
        from = 900
        to   = 0
      }
    }

    annotations = {
      description = <<EOT
Memory major pages are occurring at very high rate at {{ $labels.instance }}, 500 major page faults per second for the last 15 minutes, is currently at {{ printf "%.2f" $value }}.
Please check that there is enough memory available at this instance.
EOT
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodememorymajorpagesfaults"
      summary     = "Memory major page faults are occurring at very high rate."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
  }

    rule {
    name      = "NodeMemoryHighUtilizationWarning"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "100 - (node_memory_MemAvailable_bytes{job=\"node-exporter\"} / node_memory_MemTotal_bytes{job=\"node-exporter\"} * 100) > 90",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })
      relative_time_range {
        from = 900
        to   = 0
      }
    }

    annotations = {
      description = <<EOT
Memory is filling up at {{ $labels.instance }}, has been above 90% for the last 15 minutes, is currently at {{ printf "%.2f\" $value }}%.
EOT
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodememoryhighutilization"
      summary     = "Host is running out of memory."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
  }
    rule {
    name      = "NodeDiskIOSaturationWarning"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "rate(node_disk_io_time_weighted_seconds_total{job=\"node-exporter\", device=~\"(/dev/)?(mmcblk.p.+|nvme.+|rbd.+|sd.+|vd.+|xvd.+|dm-.+|md.+|dasd.+)\"}[5m]) > 10",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })
      relative_time_range {
        from = 1800
        to   = 0
      }
    }

    annotations = {
      description = <<EOT
Disk IO queue (aqu-sq) is high on {{ $labels.device }} at {{ $labels.instance }}, has been above 10 for the last 30 minutes, is currently at {{ printf "%.2f" $value }}.
This symptom might indicate disk saturation.
EOT
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodediskiosaturation"
      summary     = "Disk IO queue is high."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
  }
    rule {
    name      = "NodeSystemdServiceFailedWarning"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "node_systemd_unit_state{job=\"node-exporter\", state=\"failed\"} == 1",
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
      description = "Systemd service {{ $labels.name }} has entered failed state at {{ $labels.instance }}"
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodesystemdservicefailed"
      summary     = "Systemd service has entered failed state."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
  }
    rule {
    name      = "NodeBondingDegradedWarning"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "(node_bonding_slaves - node_bonding_active) != 0",
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
      description = "Bonding interface {{ $labels.master }} on {{ $labels.instance }} is in degraded state due to one or more slave failures."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/node/nodebondingdegraded"
      summary     = "Bonding interface is degraded"
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
  }
}