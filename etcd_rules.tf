resource "grafana_rule_group" "etcd_rules" {
  org_id           = 1
  folder_uid       = grafana_folder.prometheus_alerts.uid
  name             = "ETCD Rules"
  interval_seconds = var.alert_interval_seconds

  rule {
    name      = "etcdMembersDown"
    condition = "C"

    data {
      ref_id = "A"
      datasource_uid = var.datasource_uid 
      model = <<EOT
{
  "editorMode": "code",
  "expr": "max without (endpoint) (sum without (instance) (up{job=~\\\".*etcd.*\\\"} == bool 0) or count without (To) (sum without (instance) (rate(etcd_network_peer_sent_failures_total{job=~\\\".*etcd.*\\\"}[120s])) > 0.01)) > 0",
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
      ref_id = "C"
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
    for            = "10m"
    annotations = {
      description = "etcd cluster \"{{ $labels.job }}\": members are down ({{ $value }})."
      summary     = "etcd cluster members are down."
    }
    labels = {
      severity = "critical"
    }
    notification_settings {
        contact_point = var.notification_settings.contact_point
        mute_timings  = var.notification_settings.mute_timings
    }
  }

  rule {
    name      = "etcdInsufficientMembers"
    condition = "C"

    data {
      ref_id = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "sum(up{job=~\\\".*etcd.*\\\"} == bool 1) without (instance) < ((count(up{job=~\\\".*etcd.*\\\"}) without (instance) + 1) / 2)",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "instant": true,
  "refId": "A"
}
EOT

      relative_time_range {
        from = 180
        to   = 0
      }
    }

    data {
      ref_id = "C"
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
        from = 180
        to   = 0
      }
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for            = "3m"
    annotations = {
      description = "etcd cluster \"{{ $labels.job }}\": insufficient members ({{ $value }})."
      summary     = "etcd cluster has insufficient number of members."
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
    name      = "etcdNoLeader"
    condition = "C"

    data {
      ref_id = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "etcd_server_has_leader{job=~\\\".*etcd.*\\\"} == 0",
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "instant": true,
  "refId": "A"
}
EOT

      relative_time_range {
        from = 60
        to   = 0
      }
    }

    data {
      ref_id = "C"
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
        from = 60
        to   = 0
      }
    }

    no_data_state  = "OK"
    exec_err_state = "OK"
    for            = "1m"
    annotations = {
      description = "etcd cluster \"{{ $labels.job }}\": member {{ $labels.instance }} has no leader."
      summary     = "etcd cluster has no leader."
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
    name      = "etcdHighNumberOfLeaderChanges"
    condition = "C"

    data {
      ref_id = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "increase((max without (instance) (etcd_server_leader_changes_seen_total{job=~\\\".*etcd.*\\\"}) or 0*absent(etcd_server_leader_changes_seen_total{job=~\\\".*etcd.*\\\"}))[15m:1m]) >= 4",
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
      ref_id = "C"
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
    for            = "5m"
    annotations = {
      description = "etcd cluster \"{{ $labels.job }}\": {{ $value }} leader changes within the last 15 minutes. Frequent elections may be a sign of insufficient resources, high network latency, or disruptions by other components and should be investigated."
      summary     = "etcd cluster has high number of leader changes."
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
    name      = "etcdHighNumberOfFailedGRPCRequestsWarning"
    condition = "C"

    data {
      ref_id = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "100 * sum(rate(grpc_server_handled_total{job=~\\\".*etcd.*\\\", grpc_code=~\\\"Unknown|FailedPrecondition|ResourceExhausted|Internal|Unavailable|DataLoss|DeadlineExceeded\\\"}[5m])) without (grpc_type, grpc_code) / sum(rate(grpc_server_handled_total{job=~\\\".*etcd.*\\\"}[5m])) without (grpc_type, grpc_code) > 1",
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
      ref_id = "C"
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
    for            = "10m"
    annotations = {
      description = "etcd cluster \"{{ $labels.job }}\": {{ $value }}% of requests for {{ $labels.grpc_method }} failed on etcd instance {{ $labels.instance }}."
      summary     = "etcd cluster has high number of failed grpc requests."
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

  rule {
    name      = "etcdHighNumberOfFailedGRPCRequestsCritical"
    condition = "C"

    data {
      ref_id = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "100 * sum(rate(grpc_server_handled_total{job=~\\\".*etcd.*\\\", grpc_code=~\\\"Unknown|FailedPrecondition|ResourceExhausted|Internal|Unavailable|DataLoss|DeadlineExceeded\\\"}[5m])) without (grpc_type, grpc_code) / sum(rate(grpc_server_handled_total{job=~\\\".*etcd.*\\\"}[5m])) without (grpc_type, grpc_code) > 5",
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
      ref_id = "C"
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
      description = "etcd cluster \"{{ $labels.job }}\": {{ $value }}% of requests for {{ $labels.grpc_method }} failed on etcd instance {{ $labels.instance }}."
      summary     = "etcd cluster has high number of failed grpc requests."
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

resource "grafana_rule_group" "etcd_slow_requests" {
  folder_uid       = grafana_folder.prometheus_alerts.uid
  name             = "ETCD Slow Requests"
  interval_seconds = var.alert_interval_seconds

  rule {
    name      = "etcdGRPCRequestsSlow"
    condition = "C"

    data {
      ref_id = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "histogram_quantile(0.99, sum(rate(grpc_server_handling_seconds_bucket{job=~\\\".*etcd.*\\\", grpc_method!=\\\"Defragment\\\", grpc_type=\\\"unary\\\"}[5m])) without(grpc_type)) > 0.15",
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
      ref_id = "C"
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
    for            = "10m"
    annotations = {
      description = "etcd cluster \"{{ $labels.job }}\": 99th percentile of gRPC requests is {{ $value }}s on etcd instance {{ $labels.instance }} for {{ $labels.grpc_method }} method."
      summary     = "etcd grpc requests are slow."
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
    name      = "etcdMemberCommunicationSlow"
    condition = "C"

    data {
      ref_id = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "histogram_quantile(0.99, rate(etcd_network_peer_round_trip_time_seconds_bucket{job=~\\\".*etcd.*\\\"}[5m])) > 0.15",
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
      ref_id = "C"
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
    for            = "10m"
    annotations = {
      description = "etcd cluster \"{{ $labels.job }}\": member communication with {{ $labels.To }} is taking {{ $value }}s on etcd instance {{ $labels.instance }}."
      summary     = "etcd cluster member communication is slow."
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
}

resource "grafana_rule_group" "etcd_disk_rules" {
  folder_uid       = grafana_folder.prometheus_alerts.uid 
  name             = "Etcd Disk Alerts"
  interval_seconds = var.alert_interval_seconds

  rule {
    name      = "etcdHighNumberOfFailedProposals"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "rate(etcd_server_proposals_failed_total{job=~\".*etcd.*\"}[15m]) > 5",
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
      description = "etcd cluster \"{{ $labels.job }}\": {{ $value }} proposal failures within the last 30 minutes on etcd instance {{ $labels.instance }}."
      summary     = "etcd cluster has high number of proposal failures."
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

  rule {
    name      = "etcdHighFsyncDurationsWarning"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "histogram_quantile(0.99, rate(etcd_disk_wal_fsync_duration_seconds_bucket{job=~\".*etcd.*\"}[5m])) > 0.5",
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
    for            = "10m"
    annotations = {
      description = "etcd cluster \"{{ $labels.job }}\": 99th percentile fsync durations are {{ $value }}s on etcd instance {{ $labels.instance }}."
      summary     = "etcd cluster 99th percentile fsync durations are too high."
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

  rule {
    name      = "etcdHighFsyncDurationsCritical"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "histogram_quantile(0.99, rate(etcd_disk_wal_fsync_duration_seconds_bucket{job=~\".*etcd.*\"}[5m])) > 1",
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
    for            = "10m"
    annotations = {
      description = "etcd cluster \"{{ $labels.job }}\": 99th percentile fsync durations are {{ $value }}s on etcd instance {{ $labels.instance }}."
      summary     = "etcd cluster 99th percentile fsync durations are too high."
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
    name      = "etcdHighCommitDurations"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "histogram_quantile(0.99, rate(etcd_disk_backend_commit_duration_seconds_bucket{job=~\".*etcd.*\"}[5m])) > 0.25",
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
    for            = "10m"
    annotations = {
      description = "etcd cluster \"{{ $labels.job }}\": 99th percentile commit durations {{ $value }}s on etcd instance {{ $labels.instance }}."
      summary     = "etcd cluster 99th percentile commit durations are too high."
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
}


resource "grafana_rule_group" "etcd_database_rules" {
  folder_uid       = grafana_folder.prometheus_alerts.uid 
  name             = "Etcd Database Alerts"
  interval_seconds = var.alert_interval_seconds

  rule {
    name      = "etcdDatabaseQuotaLowSpace"
    condition = "C"

    data {
      ref_id = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "(last_over_time(etcd_mvcc_db_total_size_in_bytes{job=~\\\".*etcd.*\\\"}[5m]) / last_over_time(etcd_server_quota_backend_bytes{job=~\\\".*etcd.*\\\"}[5m]))*100 > 95",
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
      ref_id = "C"
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
      description = "etcd cluster \"{{ $labels.job }}\": database size exceeds the defined quota on etcd instance {{ $labels.instance }}, please defrag or increase the quota as the writes to etcd will be disabled when it is full."
      summary     = "etcd cluster database is running full."
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
    name      = "etcdExcessiveDatabaseGrowth"
    condition = "C"

    data {
      ref_id = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "predict_linear(etcd_mvcc_db_total_size_in_bytes{job=~\\\".*etcd.*\\\"}[4h], 4*60*60) > etcd_server_quota_backend_bytes{job=~\\\".*etcd.*\\\"}",
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
      ref_id = "C"
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
      description = "etcd cluster \"{{ $labels.job }}\": Predicting running out of disk space in the next four hours, based on write observations within the past four hours on etcd instance {{ $labels.instance }}, please check as it might be disruptive."
      summary     = "etcd cluster database growing very fast."
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

  rule {
    name      = "etcdDatabaseHighFragmentationRatio"
    condition = "C"

    data {
      ref_id = "A"
      datasource_uid = var.datasource_uid
      model = <<EOT
{
  "editorMode": "code",
  "expr": "(last_over_time(etcd_mvcc_db_total_size_in_use_in_bytes{job=~\\\".*etcd.*\\\"}[5m]) / last_over_time(etcd_mvcc_db_total_size_in_bytes{job=~\\\".*etcd.*\\\"}[5m])) < 0.5 and etcd_mvcc_db_total_size_in_use_in_bytes{job=~\\\".*etcd.*\\\"} > 104857600",
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
      ref_id = "C"
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
      description = "etcd cluster \"{{ $labels.job }}\": database size in use on instance {{ $labels.instance }} is {{ $value | humanizePercentage }} of the actual allocated disk space, please run defragmentation (e.g. etcdctl defrag) to retrieve the unused fragmented disk space."
      runbook_url = "https://etcd.io/docs/v3.5/op-guide/maintenance/#defragmentation"
      summary     = "etcd database size in use is less than 50% of the actual allocated storage."
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
}
