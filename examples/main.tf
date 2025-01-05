module "grafana_managed_prometheus_rules" {
  source  = "../"
  datasource_uid = "ID_HERE"
  prometheus_namespace = "monitoring"
  notification_settings = {
    contact_point = "team-infrastructure-notifications"
    mute_timings  = []
    group_by      = ["namespace", "pod"]
  }
  alert_interval_seconds = 60
  config_reloader_rules_enabled = true
  prometheus_alerts_enabled = true
  kubernetes_apps_alerts_enabled = true
  kubernetes_storage_alerts_enabled = true
  kube_state_metrics_errors_alerts_enabled = true
  node_network_interface_alerts_enabled = true
  node_exporter_alerts_enabled = true

  prometheus_general_rules_enabled = false
  container_cpu_usage_rules_enabled = false
  container_memory_rss_rules_enabled = false
  container_memory_working_set_rules_enabled = false
  container_resource_rules_enabled = false
  general_rules_enabled = false  
  alertmanager_rules_enabled = false
  apiserver_request_error_rates_enabled = false
  
  // on eks dont need
  etcd_rules_enabled = false
  etcd_slow_requests_enabled = false
  etcd_disk_rules_enabled = false
  etcd_database_rules_enabled = false
  kube_apiserver_availability_rules_enabled = false
  kube_apiserver_histogram_rules_enabled = false
}
