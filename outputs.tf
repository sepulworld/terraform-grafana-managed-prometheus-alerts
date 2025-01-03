output "etcd_rule_id" {
  value = grafana_rule_group.etcd_rules.id
}

output "etcd_rule_slow_query_uid" {
  value = grafana_rule_group.etcd_slow_requests.id
}

output "config_reloader_rule_id" {
  value = grafana_rule_group.config_reloader_rules.id 
}