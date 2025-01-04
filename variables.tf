variable "datasource_uid" {
  type = string
  description = "The ID of the Prometheus datasource to be used, example P220FC6EABAB2D0ZS"
}

variable "prometheus_namespace" {
  type = string
  description = "The namespace of the Prometheus instance"
  default = "prometheus"
}

variable "config_reloader_rules_enabled" {
  type = bool
  description = "Enable or disable the config reload rule"
  default = true
}

variable "container_memory_swap_rules_enabled" {
  type = bool
  description = "Enable or disable the container memory swap rule"
  default = true
}

variable "container_memory_cache_rules_enabled" {
  type = bool
  description = "Enable or disable the container memory cache rule"
  default = true
}

variable "container_cpu_usage_rules_enabled" {
  type = bool
  description = "Enable or disable the container CPU usage rule"
  default = true
}

variable "container_memory_rss_rules_enabled" {
  type = bool
  description = "Enable or disable the container memory RSS rule"
  default = true
}

variable "container_memory_working_set_rules_enabled" {
  type = bool
  description = "Enable or disable the container memory working set rule"
  default = true
}

variable "container_resource_rules_enabled" {
  type = bool
  description = "Enable or disable the container resource rule"
  default = true
}

variable "etcd_rules_enabled" {
  type = bool
  description = "Enable or disable the etcd rule"
  default = true
}

variable "etcd_slow_requests_enabled" {
  type = bool
  description = "Enable or disable the etcd slow requests rule"
  default = true
}

variable "etcd_disk_rules_enabled" {
  type = bool
  description = "Enable or disable the etcd disk related rule"
  default = true
}

variable "etcd_database_rules_enabled" {
  type = bool
  description = "Enable or disable the etcd database related rule"
  default = true
}

variable "general_rules_enabled" {
  type = bool
  description = "Enable or disable the general rules"
  default = true
}
variable "apiserver_request_error_rates_enabled" {
  type = bool
  description = "Enable or disable the kube-apiserver request error rate rule"
  default = true
}
variable "kube_apiserver_availability_rules_enabled" {
  type = bool
  description = "Enable or disable the kube-apiserver availability rule"
  default = true
}

variable "kube_apiserver_histogram_rules_enabled" {
  type = bool
  description = "Enable or disable the kube-apiserver histogram rule"
  default = true
}

variable "prometheus_general_rules_enabled" {
  type = bool
  description = "Enable or disable the Prometheus general rule"
  default = true
}

variable "prometheus_general_recording_rules_enabled" {
  type = bool
  description = "Enable or disable the Prometheus general recording rule"
  default = true
}

variable "prometheus_alerts_enabled" {
  type = bool
  description = "Enable or disable the Prometheus alerting rule"
  default = true
}

variable "alertmanager_rules_enabled" {
  type = bool
  description = "Enable or disable the Alertmanager rule"
  default = true
}

variable "kubernetes_apps_alerts_enabled" {
  type = bool
  description = "Enable or disable the Kubernetes apps alert rule"
  default = true
}

variable "grafana_org_id" {
  type = number
  description = "The ID of the Grafana organization"
  default = 1
}

variable "alert_interval_seconds" {
  type = number
  description = "The interval in seconds to check for alerts"
  default = 60
}

variable "notification_settings" {
    type = object({
        contact_point = string
        group_by      = list(string)
        mute_timings  = list(string)
    })
    description = "The notification settings for the alerts"
    default = {
        contact_point = "team-infrastructure-notifications"
        group_by      = ["namespace", "pod"]
        mute_timings  = null
    }
}