output "etcd_rule_id" {
  value = try(grafana_rule_group.etcd_rules[0].id, null)
}

output "etcd_rule_slow_query_uid" {
  value = try(grafana_rule_group.etcd_slow_requests[0].id, null)
}

output "config_reloader_rule_id" {
  value = try(grafana_rule_group.config_reloader_rules[0].id, null)
}