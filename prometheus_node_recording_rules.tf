resource "grafana_rule_group" "kube_prometheus_general_recording_rules" {
  name             = "kube_prometheus_general_rules"
  folder_uid       = grafana_folder.prometheus_alerts.uid
  interval_seconds = var.alert_interval_seconds

  rule {
    name      = "CountUp1"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
count without(instance, pod, node) (up == 1)
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 300 # 5 minutes
        to   = 0
      }
    }

    annotations = {
      description = "Counts the number of targets that are up."
    }

    labels = {
      record = "count:up1"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
  }

  rule {
    name      = "CountUp0"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
count without(instance, pod, node) (up == 0)
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 300 # 5 minutes
        to   = 0
      }
    }

    annotations = {
      description = "Counts the number of targets that are down."
    }

    labels = {
      record = "count:up0"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
  }
    # Rule 1: Disk Read Bytes Rate
  rule {
    name      = "InstanceNodeDiskReadBytesRateSum"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
sum(rate(node_disk_read_bytes_total[3m])) BY (instance)
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 300 # 5 minutes
        to   = 0
      }
    }

    annotations = {
      description = "Calculates the disk read bytes rate per instance over a 3-minute window."
    }

    labels = {
      record = "instance:node_disk_read_bytes:rate:sum"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
  }

  # Rule 2: Disk Write Bytes Rate
  rule {
    name      = "InstanceNodeDiskWriteBytesRateSum"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
sum(rate(node_disk_write_bytes_total[3m])) BY (instance)
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 300 # 5 minutes
        to   = 0
      }
    }

    annotations = {
      description = "Calculates the disk write bytes rate per instance over a 3-minute window."
    }

    labels = {
      record = "instance:node_disk_write_bytes:rate:sum"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
  }

  # Rule 3: Memory Available Ratio
  rule {
    name      = "InstanceNodeMemoryAvailableRatio"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
avg(node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) BY (instance)
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 300 # 5 minutes
        to   = 0
      }
    }

    annotations = {
      description = "Calculates the ratio of available memory to total memory per instance."
    }

    labels = {
      record = "instance:node_memory:available_ratio"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
  }
    rule {
    name      = "ClusterNodeCpuRatio"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
cluster:node_cpu:sum_rate5m / count(sum(node_cpu_seconds_total) BY (instance, cpu))
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 300 # 5 minutes
        to   = 0
      }
    }

    annotations = {
      description = "Calculates the CPU usage ratio for the cluster by dividing the sum of CPU rates by the count of CPUs across instances."
    }

    labels = {
      record = "cluster:node_cpu:ratio"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
  }
}