resource "grafana_rule_group" "alertmanager_rules" {
  count            = var.alertmanager_rules_enabled ? 1 : 0
  folder_uid       = grafana_folder.prometheus_alerts.uid
  name             = "Alertmanager Rules"
  interval_seconds = var.alert_interval_seconds

  # AlertmanagerFailedReload
  rule {
    name      = "AlertmanagerFailedReload"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "max_over_time(alertmanager_config_last_reload_successful{job=~\\\"prometheus-kube-prometheus-alertmanager\\\",namespace=~\\\"${var.prometheus_namespace}\\\"}[5m]) == 0",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "instant": true,
  "refId": "A"
}
EOT
      relative_time_range {
        from = 300
        to   = 0
      }
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = <<EOT
{
  "conditions": [
    {
      "evaluator": {
        "type": "gt",
        "params": [0]
      },
      "operator": {
        "type": "and"
      },
      "query": {
        "params": ["A"]
      },
      "reducer": {
        "type": "last"
      },
      "type": "query"
    }
  ],
  "datasource": {
    "type": "__expr__",
    "uid": "__expr__"
  },
  "expression": "A",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "refId": "C",
  "type": "threshold"
}
EOT
      relative_time_range {
        from = 300
        to   = 0
      }
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for            = "10m"

    annotations = {
      description = "Configuration has failed to load for {{ $labels.namespace }}/{{ $labels.pod }}."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/alertmanager/alertmanagerfailedreload"
      summary     = "Reloading an Alertmanager configuration has failed."
    }
    labels = {
      severity = "critical"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
  }

  # Additional rules in the group

  # AlertmanagerMembersInconsistent
  rule {
    name      = "AlertmanagerMembersInconsistent"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "max_over_time(alertmanager_cluster_members{job=~\\\"prometheus-kube-prometheus-alertmanager\\\",namespace=~\\\"${var.prometheus_namespace}\\\"}[5m]) < on (namespace,service,cluster) group_left count by (namespace,service,cluster) (max_over_time(alertmanager_cluster_members{job=~\\\"prometheus-kube-prometheus-alertmanager\\\",namespace=~\\\"${var.prometheus_namespace}\\\"}[5m]))",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "instant": true,
  "refId": "A"
}
EOT
      relative_time_range {
        from = 900
        to   = 0
      }
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = <<EOT
{
  "conditions": [
    {
      "evaluator": {
        "type": "gt",
        "params": [0]
      },
      "operator": {
        "type": "and"
      },
      "query": {
        "params": ["A"]
      },
      "reducer": {
        "type": "last"
      },
      "type": "query"
    }
  ],
  "datasource": {
    "type": "__expr__",
    "uid": "__expr__"
  },
  "expression": "A",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "refId": "C",
  "type": "threshold"
}
EOT
      relative_time_range {
        from = 900
        to   = 0
      }
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for            = "15m"

    annotations = {
      description = "Alertmanager {{ $labels.namespace }}/{{ $labels.pod }} has only found {{ $value }} members of the {{$labels.job}} cluster."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/alertmanager/alertmanagermembersinconsistent"
      summary     = "A member of an Alertmanager cluster has not found all other cluster members."
    }
    labels = {
      severity = "critical"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
  }

   # AlertmanagerFailedToSendAlerts
  rule {
    name      = "AlertmanagerFailedToSendAlerts"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "rate(alertmanager_notifications_failed_total{job=~\\\"prometheus-kube-prometheus-alertmanager\\\",namespace=~\\\"${var.prometheus_namespace}\\\"}[5m]) / ignoring (reason) group_left rate(alertmanager_notifications_total{job=~\\\"prometheus-kube-prometheus-alertmanager\\\",namespace=~\\\"${var.prometheus_namespace}\\\"}[5m]) > 0.01",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "instant": true,
  "refId": "A"
}
EOT
      relative_time_range {
        from = 300
        to   = 0
      }
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = <<EOT
{
  "conditions": [
    {
      "evaluator": {
        "type": "gt",
        "params": [0]
      },
      "operator": {
        "type": "and"
      },
      "query": {
        "params": ["A"]
      },
      "reducer": {
        "type": "last"
      },
      "type": "query"
    }
  ],
  "datasource": {
    "type": "__expr__",
    "uid": "__expr__"
  },
  "expression": "A",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "refId": "C",
  "type": "threshold"
}
EOT
      relative_time_range {
        from = 300
        to   = 0
      }
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for            = "5m"

    annotations = {
      description = "Alertmanager {{ $labels.namespace }}/{{ $labels.pod }} failed to send {{ $value | humanizePercentage }} of notifications to {{ $labels.integration }}."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/alertmanager/alertmanagerfailedtosendalerts"
      summary     = "An Alertmanager instance failed to send notifications."
    }
    labels = {
      severity = "warning"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
  }

  # AlertmanagerClusterFailedToSendAlerts
  rule {
    name      = "AlertmanagerClusterFailedToSendAlerts"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "min by (namespace,service,integration) (rate(alertmanager_notifications_failed_total{job=~\\\"prometheus-kube-prometheus-alertmanager\\\",namespace=~\\\"${var.prometheus_namespace}\\\",integration=~\\\".*\\\"}[5m]) / ignoring (reason) group_left rate(alertmanager_notifications_total{job=~\\\"prometheus-kube-prometheus-alertmanager\\\",namespace=~\\\"${var.prometheus_namespace}\\\",integration=~\\\".*\\\"}[5m])) > 0.01",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "instant": true,
  "refId": "A"
}
EOT
      relative_time_range {
        from = 300
        to   = 0
      }
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = <<EOT
{
  "conditions": [
    {
      "evaluator": {
        "type": "gt",
        "params": [0]
      },
      "operator": {
        "type": "and"
      },
      "query": {
        "params": ["A"]
      },
      "reducer": {
        "type": "last"
      },
      "type": "query"
    }
  ],
  "datasource": {
    "type": "__expr__",
    "uid": "__expr__"
  },
  "expression": "A",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "refId": "C",
  "type": "threshold"
}
EOT
      relative_time_range {
        from = 300
        to   = 0
      }
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for            = "5m"

    annotations = {
      description = "The minimum notification failure rate to {{ $labels.integration }} sent from any instance in the {{$labels.job}} cluster is {{ $value | humanizePercentage }}."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/alertmanager/alertmanagerclusterfailedtosendalerts"
      summary     = "All Alertmanager instances in a cluster failed to send notifications to a critical integration."
    }
    labels = {
      severity = "critical"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
  }
    rule {
    name      = "AlertmanagerClusterFailedToSendAlerts"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "min by (namespace,service,integration) (rate(alertmanager_notifications_failed_total{job=~\\\"prometheus-kube-prometheus-alertmanager\\\",namespace=~\\\"${var.prometheus_namespace}\\\",integration!~\\\".*\\\"}[5m]) / ignoring (reason) group_left rate(alertmanager_notifications_total{job=~\\\"prometheus-kube-prometheus-alertmanager\\\",namespace=~\\\"${var.prometheus_namespace}\\\",integration!~\\\".*\\\"}[5m])) > 0.01",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "instant": true,
  "refId": "A"
}
EOT
      relative_time_range {
        from = 300
        to   = 0
      }
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = <<EOT
{
  "conditions": [
    {
      "evaluator": {
        "type": "gt",
        "params": [0]
      },
      "operator": {
        "type": "and"
      },
      "query": {
        "params": ["A"]
      },
      "reducer": {
        "type": "last"
      },
      "type": "query"
    }
  ],
  "datasource": {
    "type": "__expr__",
    "uid": "__expr__"
  },
  "expression": "A",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "refId": "C",
  "type": "threshold"
}
EOT
      relative_time_range {
        from = 300
        to   = 0
      }
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for            = "5m"

    annotations = {
      description = "The minimum notification failure rate to {{ $labels.integration }} sent from any instance in the {{$labels.job}} cluster is {{ $value | humanizePercentage }}."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/alertmanager/alertmanagerclusterfailedtosendalerts"
      summary     = "All Alertmanager instances in a cluster failed to send notifications to a non-critical integration."
    }
    labels = {
      severity = "warning"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
  }

  # AlertmanagerConfigInconsistent
  rule {
    name      = "AlertmanagerConfigInconsistent"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "count by (namespace,service,cluster) (count_values by (namespace,service,cluster) (\\\"config_hash\\\", alertmanager_config_hash{job=~\\\"prometheus-kube-prometheus-alertmanager\\\",namespace=~\\\"${var.prometheus_namespace}\\\"})) != 1",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "instant": true,
  "refId": "A"
}
EOT
      relative_time_range {
        from = 1200
        to   = 0
      }
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = <<EOT
{
  "conditions": [
    {
      "evaluator": {
        "type": "gt",
        "params": [0]
      },
      "operator": {
        "type": "and"
      },
      "query": {
        "params": ["A"]
      },
      "reducer": {
        "type": "last"
      },
      "type": "query"
    }
  ],
  "datasource": {
    "type": "__expr__",
    "uid": "__expr__"
  },
  "expression": "A",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "refId": "C",
  "type": "threshold"
}
EOT
      relative_time_range {
        from = 1200
        to   = 0
      }
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for            = "20m"

    annotations = {
      description = "Alertmanager instances within the {{$labels.job}} cluster have different configurations."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/alertmanager/alertmanagerconfiginconsistent"
      summary     = "Alertmanager instances within the same cluster have different configurations."
    }
    labels = {
      severity = "critical"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
  }

    # AlertmanagerClusterDown
  rule {
    name      = "AlertmanagerClusterDown"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "((count by (namespace,service,cluster) (avg_over_time(up{job=~\\\"prometheus-kube-prometheus-alertmanager\\\",namespace=~\\\"${var.prometheus_namespace}\\\"}[5m]) < 0.5)) / count by (namespace,service,cluster) (up{job=~\\\"prometheus-kube-prometheus-alertmanager\\\",namespace=~\\\"${var.prometheus_namespace}\\\"})) >= 0.5",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "instant": true,
  "refId": "A"
}
EOT
      relative_time_range {
        from = 300
        to   = 0
      }
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = <<EOT
{
  "conditions": [
    {
      "evaluator": {
        "type": "gt",
        "params": [0]
      },
      "operator": {
        "type": "and"
      },
      "query": {
        "params": ["A"]
      },
      "reducer": {
        "type": "last"
      },
      "type": "query"
    }
  ],
  "datasource": {
    "type": "__expr__",
    "uid": "__expr__"
  },
  "expression": "A",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "refId": "C",
  "type": "threshold"
}
EOT
      relative_time_range {
        from = 300
        to   = 0
      }
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for            = "5m"

    annotations = {
      description = "{{ $value | humanizePercentage }} of Alertmanager instances within the {{$labels.job}} cluster have been up for less than half of the last 5m."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/alertmanager/alertmanagerclusterdown"
      summary     = "Half or more of the Alertmanager instances within the same cluster are down."
    }
    labels = {
      severity = "critical"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
  }

  # AlertmanagerClusterCrashlooping
  rule {
    name      = "AlertmanagerClusterCrashlooping"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "((count by (namespace,service,cluster) (changes(process_start_time_seconds{job=~\\\"prometheus-kube-prometheus-alertmanager\\\",namespace=~\\\"${var.prometheus_namespace}\\\"}[10m]) > 4)) / count by (namespace,service,cluster) (up{job=~\\\"prometheus-kube-prometheus-alertmanager\\\",namespace=~\\\"${var.prometheus_namespace}\\\"})) >= 0.5",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "instant": true,
  "refId": "A"
}
EOT
      relative_time_range {
        from = 600
        to   = 0
      }
    }

    data {
      ref_id         = "C"
      datasource_uid = "__expr__"
      model = <<EOT
{
  "conditions": [
    {
      "evaluator": {
        "type": "gt",
        "params": [0]
      },
      "operator": {
        "type": "and"
      },
      "query": {
        "params": ["A"]
      },
      "reducer": {
        "type": "last"
      },
      "type": "query"
    }
  ],
  "datasource": {
    "type": "__expr__",
    "uid": "__expr__"
  },
  "expression": "A",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "refId": "C",
  "type": "threshold"
}
EOT
      relative_time_range {
        from = 600
        to   = 0
      }
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for            = "5m"

    annotations = {
      description = "{{ $value | humanizePercentage }} of Alertmanager instances within the {{$labels.job}} cluster have restarted at least 5 times in the last 10m."
      runbook_url = "https://runbooks.prometheus-operator.dev/runbooks/alertmanager/alertmanagerclustercrashlooping"
      summary     = "Half or more of the Alertmanager instances within the same cluster are crashlooping."
    }
    labels = {
      severity = "critical"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
  }
}