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