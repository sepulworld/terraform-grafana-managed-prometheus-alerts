resource "grafana_rule_group" "node_network_interface_flapping" {
  count            = var.node_network_interface_flapping_rules_enabled ? 1 : 0
  name             = "node_network_interface_flapping"
  folder_uid       = grafana_folder.prometheus_alerts.uid
  interval_seconds = var.alert_interval_seconds

  rule {
    name      = "NodeNetworkInterfaceFlapping"
    condition = "A"

    # Data Query
    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
changes(node_network_up{job="node-exporter",device!~"veth.+"}[2m]) > 2
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "refId"         = "A"
      })

      relative_time_range {
        from = 120 # Last 2 minutes
        to   = 0   # Current time
      }
    }

    annotations = {
      description = "Network interface \"{{ $labels.device }}\" changing its up status often on node-exporter {{ $labels.namespace }}/{{ $labels.pod }}."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/general/nodenetworkinterfaceflapping"
      summary     = "Network interface is often changing its status."
    }

    labels = {
      severity = "warning"
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for           = "2m"

    notification_settings {
      contact_point = var.notification_settings.contact_point
      group_by      = ["namespace", "pod", "device"]
      mute_timings  = var.notification_settings.mute_timings
    }
  }
}
