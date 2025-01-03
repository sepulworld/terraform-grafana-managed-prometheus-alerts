resource "grafana_rule_group" "kube_apiserver_availability_rules" {
  name             = "kube_apiserver_availability_rules"
  folder_uid       = grafana_folder.prometheus_alerts.uid
  interval_seconds = 180 # 3 minutes

  rule {
    name      = "ApiserverRequestTotalIncrease30d"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "avg_over_time(code_verb:apiserver_request_total:increase1h[30d]) * 24 * 30",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 2592000 # 30 days in seconds
        to   = 0
      }
    }

    annotations = {
      description = "Average number of API server requests over the last 30 days, extrapolated to a 30-day period."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
group_by = var.notification_settings.group_by
    }
  }

    rule {
    name      = "ApiserverRequestTotalIncrease30dRead"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "sum by (cluster, code) (code_verb:apiserver_request_total:increase30d{verb=~\"LIST|GET\"})",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 2592000 # 30 days in seconds
        to   = 0
      }
    }

    annotations = {
      description = "API server request totals for read operations (LIST/GET) over 30 days."
    }

    labels = {
      verb = "read"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
group_by = var.notification_settings.group_by
    }
  }

  rule {
    name      = "ApiserverRequestTotalIncrease30dWrite"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "sum by (cluster, code) (code_verb:apiserver_request_total:increase30d{verb=~\"POST|PUT|PATCH|DELETE\"})",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 2592000 # 30 days in seconds
        to   = 0
      }
    }

    annotations = {
      description = "API server request totals for write operations (POST/PUT/PATCH/DELETE) over 30 days."
    }

    labels = {
      verb = "write"
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
group_by = var.notification_settings.group_by
    }
  }

  rule {
    name      = "ApiserverRequestSLIDurationIncrease1h"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "sum by (cluster, verb, scope) (increase(apiserver_request_sli_duration_seconds_count{job=\"apiserver\"}[1h]))",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 3600 # 1 hour in seconds
        to   = 0
      }
    }

    annotations = {
      description = "Increase in API server request SLI duration counts for the past 1 hour, grouped by cluster, verb, and scope."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
group_by = var.notification_settings.group_by
    }
  }

    rule {
    name      = "ApiserverRequestSLIDurationIncrease30d"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "sum by (cluster, verb, scope) (avg_over_time(cluster_verb_scope:apiserver_request_sli_duration_seconds_count:increase1h[30d]) * 24 * 30)",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 2592000 # 30 days in seconds
        to   = 0
      }
    }

    annotations = {
      description = "Increase in API server request SLI duration counts over the past 30 days, grouped by cluster, verb, and scope."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
group_by = var.notification_settings.group_by
    }
  }

  rule {
    name      = "ApiserverRequestSLIBucketIncrease1h"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "sum by (cluster, verb, scope, le) (increase(apiserver_request_sli_duration_seconds_bucket[1h]))",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 3600 # 1 hour in seconds
        to   = 0
      }
    }

    annotations = {
      description = "Increase in API server request SLI duration buckets over the past 1 hour, grouped by cluster, verb, scope, and le."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
group_by = var.notification_settings.group_by
    }
  }

  rule {
    name      = "ApiserverRequestSLIBucketIncrease30d"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = "sum by (cluster, verb, scope, le) (avg_over_time(cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase1h[30d]) * 24 * 30)",
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 2592000 # 30 days in seconds
        to   = 0
      }
    }

    annotations = {
      description = "Increase in API server request SLI duration buckets over the past 30 days, grouped by cluster, verb, scope, and le."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
group_by = var.notification_settings.group_by
    }
  }
    # Rule 1: apiserver_request:availability30d (All Verbs)
  rule {
    name      = "ApiserverRequestAvailability30dAllVerbs"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
1 - (
  (
    sum by (cluster) (cluster_verb_scope:apiserver_request_sli_duration_seconds_count:increase30d{verb=~"POST|PUT|PATCH|DELETE"})
    -
    sum by (cluster) (cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase30d{verb=~"POST|PUT|PATCH|DELETE",le="1"})
  ) +
  (
    sum by (cluster) (cluster_verb_scope:apiserver_request_sli_duration_seconds_count:increase30d{verb=~"LIST|GET"})
    -
    (
      (
        sum by (cluster) (cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase30d{verb=~"LIST|GET",scope=~"resource|",le="1"})
        or
        vector(0)
      )
      +
      sum by (cluster) (cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase30d{verb=~"LIST|GET",scope="namespace",le="5"})
      +
      sum by (cluster) (cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase30d{verb=~"LIST|GET",scope="cluster",le="30"})
    )
  ) +
  sum by (cluster) (code:apiserver_request_total:increase30d{code=~"5.."} or vector(0))
)
/
sum by (cluster) (code:apiserver_request_total:increase30d)
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 2592000 # 30 days
        to   = 0
      }
    }

    labels = {
      verb = "all"
    }

    annotations = {
      description = "Availability of API server requests over the past 30 days for all verbs."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
group_by = var.notification_settings.group_by
    }
  }

  # Rule 2: apiserver_request:availability30d (Read Verbs)
  rule {
    name      = "ApiserverRequestAvailability30dReadVerbs"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
1 - (
  sum by (cluster) (cluster_verb_scope:apiserver_request_sli_duration_seconds_count:increase30d{verb=~"LIST|GET"})
  -
  (
    (
      sum by (cluster) (cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase30d{verb=~"LIST|GET",scope=~"resource|",le="1"})
      or
      vector(0)
    )
    +
    sum by (cluster) (cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase30d{verb=~"LIST|GET",scope="namespace",le="5"})
    +
    sum by (cluster) (cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase30d{verb=~"LIST|GET",scope="cluster",le="30"})
  )
  +
  sum by (cluster) (code:apiserver_request_total:increase30d{verb="read",code=~"5.."} or vector(0))
)
/
sum by (cluster) (code:apiserver_request_total:increase30d{verb="read"})
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 2592000 # 30 days
        to   = 0
      }
    }

    labels = {
      verb = "read"
    }

    annotations = {
      description = "Availability of API server requests over the past 30 days for read verbs."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
group_by = var.notification_settings.group_by
    }
  }
    # Rule 1: apiserver_request:availability30d
  rule {
    name      = "ApiserverRequestAvailability30d"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
1 - (
  (
    # too slow
    sum by (cluster) (cluster_verb_scope:apiserver_request_sli_duration_seconds_count:increase30d{verb=~"POST|PUT|PATCH|DELETE"})
    -
    sum by (cluster) (cluster_verb_scope_le:apiserver_request_sli_duration_seconds_bucket:increase30d{verb=~"POST|PUT|PATCH|DELETE",le="1"})
  )
  +
  # errors
  sum by (cluster) (code:apiserver_request_total:increase30d{verb="write",code=~"5.."} or vector(0))
)
/
sum by (cluster) (code:apiserver_request_total:increase30d{verb="write"})
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 2592000 # 30 days
        to   = 0
      }
    }

    labels = {
      verb = "write"
    }

    annotations = {
      description = "Availability of API server write requests over the past 30 days."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
group_by = var.notification_settings.group_by
    }
  }

  # Rule 2: code_resource:apiserver_request_total:rate5m
  rule {
    name      = "ApiserverRequestRate5m"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
sum by (cluster,code,resource) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[5m]))
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

    labels = {
      verb = "read"
    }

    annotations = {
      description = "Rate of API server read requests by cluster, code, and resource over 5 minutes."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
group_by = var.notification_settings.group_by
    }
  }
    # Rule 1: code_resource:apiserver_request_total:rate5m
  rule {
    name      = "ApiserverRequestRate5m"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
sum by (cluster,code,resource) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[5m]))
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

    labels = {
      verb = "write"
    }

    annotations = {
      description = "Rate of API server write requests (POST, PUT, PATCH, DELETE) over 5 minutes."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
group_by = var.notification_settings.group_by
    }
  }

  # Rule 2: code_verb:apiserver_request_total:increase1h (2xx codes)
  rule {
    name      = "ApiserverRequestIncrease1h_2xx"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
sum by (cluster, code, verb) (increase(apiserver_request_total{job="apiserver",verb=~"LIST|GET|POST|PUT|PATCH|DELETE",code=~"2.."}[1h]))
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 3600 # 1 hour
        to   = 0
      }
    }

    annotations = {
      description = "Increase in API server requests (2xx codes) over 1 hour by cluster, code, and verb."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
group_by = var.notification_settings.group_by
    }
  }

  # Rule 3: code_verb:apiserver_request_total:increase1h (3xx codes)
  rule {
    name      = "ApiserverRequestIncrease1h_3xx"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
sum by (cluster, code, verb) (increase(apiserver_request_total{job="apiserver",verb=~"LIST|GET|POST|PUT|PATCH|DELETE",code=~"3.."}[1h]))
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 3600 # 1 hour
        to   = 0
      }
    }

    annotations = {
      description = "Increase in API server requests (3xx codes) over 1 hour by cluster, code, and verb."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
group_by = var.notification_settings.group_by
    }
  }
}

resource "grafana_rule_group" "apiserver_request_error_rates" {
  name             = "apiserver_request_error_rates"
  folder_uid       = grafana_folder.prometheus_alerts.uid
  interval_seconds = 3600 # 1 hour

  # Rule 1: code_verb:apiserver_request_total:increase1h (4xx codes)
  rule {
    name      = "ApiserverRequestIncrease1h_4xx"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
sum by (cluster, code, verb) (increase(apiserver_request_total{job="apiserver",verb=~"LIST|GET|POST|PUT|PATCH|DELETE",code=~"4.."}[1h]))
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 3600 # 1 hour
        to   = 0
      }
    }

    annotations = {
      description = "Increase in API server requests (4xx codes) over 1 hour by cluster, code, and verb."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
group_by = var.notification_settings.group_by
    }
  }

  # Rule 2: code_verb:apiserver_request_total:increase1h (5xx codes)
  rule {
    name      = "ApiserverRequestIncrease1h_5xx"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
sum by (cluster, code, verb) (increase(apiserver_request_total{job="apiserver",verb=~"LIST|GET|POST|PUT|PATCH|DELETE",code=~"5.."}[1h]))
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 3600 # 1 hour
        to   = 0
      }
    }

    annotations = {
      description = "Increase in API server requests (5xx codes) over 1 hour by cluster, code, and verb."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
group_by = var.notification_settings.group_by
    }
  }
    # Rule 1: code_verb:apiserver_request_total:increase1h (4xx codes)
  rule {
    name      = "ApiserverRequestIncrease1h_4xx"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
sum by (cluster, code, verb) (increase(apiserver_request_total{job="apiserver",verb=~"LIST|GET|POST|PUT|PATCH|DELETE",code=~"4.."}[1h]))
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 3600 # 1 hour
        to   = 0
      }
    }

    annotations = {
      description = "Increase in API server requests (4xx codes) over 1 hour by cluster, code, and verb."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
  }

  rule {
    name      = "ApiserverRequestIncrease1h_5xx"
    condition = "A"

    data {
      ref_id         = "A"
      datasource_uid = var.datasource_uid
      model = jsonencode({
        "editorMode"    = "code",
        "expr"          = <<EOT
sum by (cluster, code, verb) (increase(apiserver_request_total{job="apiserver",verb=~"LIST|GET|POST|PUT|PATCH|DELETE",code=~"5.."}[1h]))
EOT
        "intervalMs"    = 1000,
        "maxDataPoints" = 43200,
        "instant"       = true,
        "refId"         = "A"
      })

      relative_time_range {
        from = 3600 # 1 hour
        to   = 0
      }
    }

    annotations = {
      description = "Increase in API server requests (5xx codes) over 1 hour by cluster, code, and verb."
    }

    notification_settings {
      contact_point = var.notification_settings.contact_point
      mute_timings  = var.notification_settings.mute_timings
      group_by = var.notification_settings.group_by
    }
  }
}