# terraform-grafana-managed-prometheus-rules

This project provides Terraform configurations for managing Prometheus rules in Grafana Cloud. It allows users to define and deploy alerting and recording rules for Prometheus using Terraform, ensuring consistent and version-controlled rule management.

The default Prometheus rules that come with prometheus-operator are not version-controlled and don't tie in nicely with Grafana managed alerts. This project aims to provide a solution for managing Prometheus rules in Grafana Cloud using Terraform.

## Features
- Define Prometheus alerting and recording rules in Terraform
- Deploy rules to Grafana Cloud
- Version control for Prometheus rules

## Usage
1. Clone the repository.
2. Update the Terraform configurations with your Prometheus rules.
3. Apply the Terraform configurations to deploy the rules to Grafana Cloud.

## Requirements
- Terraform

## License
This project is licensed under the MIT License.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_grafana"></a> [grafana](#provider\_grafana) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [grafana_folder.prometheus_alerts](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [grafana_rule_group.alertmanager_rules](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.apiserver_request_error_rates](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.config_reloader_rules](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.etcd_database_rules](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.etcd_disk_rules](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.etcd_rules](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.etcd_slow_requests](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.k8s_container_cpu_usage](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.k8s_container_memory_cache](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.k8s_container_memory_rss](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.k8s_container_memory_swap](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.k8s_container_memory_working_set_bytes](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.k8s_container_resource](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.k8s_container_resource_limits](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.kube_apiserver_availability_rules](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.kube_apiserver_histogram_rules](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.kube_persistent_volume_alerts](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.kube_prometheus_general_alerts](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.kube_prometheus_general_rules](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.kube_state_metrics_errors](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.kubernetes_apps](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.node_exporter_alerts](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.node_network_interface_flapping](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.prometheus_alerts](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |
| [grafana_rule_group.target_down_and_watchdog](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/rule_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_interval_seconds"></a> [alert\_interval\_seconds](#input\_alert\_interval\_seconds) | The interval in seconds to check for alerts | `number` | `60` | no |
| <a name="input_alertmanager_rules_enabled"></a> [alertmanager\_rules\_enabled](#input\_alertmanager\_rules\_enabled) | Enable or disable the Alertmanager rule | `bool` | `true` | no |
| <a name="input_apiserver_request_error_rates_enabled"></a> [apiserver\_request\_error\_rates\_enabled](#input\_apiserver\_request\_error\_rates\_enabled) | Enable or disable the kube-apiserver request error rate rule | `bool` | `true` | no |
| <a name="input_config_reloader_rules_enabled"></a> [config\_reloader\_rules\_enabled](#input\_config\_reloader\_rules\_enabled) | Enable or disable the config reload rule | `bool` | `true` | no |
| <a name="input_container_cpu_usage_rules_enabled"></a> [container\_cpu\_usage\_rules\_enabled](#input\_container\_cpu\_usage\_rules\_enabled) | Enable or disable the container CPU usage rule | `bool` | `true` | no |
| <a name="input_container_memory_cache_rules_enabled"></a> [container\_memory\_cache\_rules\_enabled](#input\_container\_memory\_cache\_rules\_enabled) | Enable or disable the container memory cache rule | `bool` | `true` | no |
| <a name="input_container_memory_rss_rules_enabled"></a> [container\_memory\_rss\_rules\_enabled](#input\_container\_memory\_rss\_rules\_enabled) | Enable or disable the container memory RSS rule | `bool` | `true` | no |
| <a name="input_container_memory_swap_rules_enabled"></a> [container\_memory\_swap\_rules\_enabled](#input\_container\_memory\_swap\_rules\_enabled) | Enable or disable the container memory swap rule | `bool` | `true` | no |
| <a name="input_container_memory_working_set_rules_enabled"></a> [container\_memory\_working\_set\_rules\_enabled](#input\_container\_memory\_working\_set\_rules\_enabled) | Enable or disable the container memory working set rule | `bool` | `true` | no |
| <a name="input_container_resource_rules_enabled"></a> [container\_resource\_rules\_enabled](#input\_container\_resource\_rules\_enabled) | Enable or disable the container resource rule | `bool` | `true` | no |
| <a name="input_datasource_uid"></a> [datasource\_uid](#input\_datasource\_uid) | The ID of the Prometheus datasource to be used, example P220FC6EABAB2D0ZS | `string` | n/a | yes |
| <a name="input_etcd_database_rules_enabled"></a> [etcd\_database\_rules\_enabled](#input\_etcd\_database\_rules\_enabled) | Enable or disable the etcd database related rule | `bool` | `true` | no |
| <a name="input_etcd_disk_rules_enabled"></a> [etcd\_disk\_rules\_enabled](#input\_etcd\_disk\_rules\_enabled) | Enable or disable the etcd disk related rule | `bool` | `true` | no |
| <a name="input_etcd_rules_enabled"></a> [etcd\_rules\_enabled](#input\_etcd\_rules\_enabled) | Enable or disable the etcd rule | `bool` | `true` | no |
| <a name="input_etcd_slow_requests_enabled"></a> [etcd\_slow\_requests\_enabled](#input\_etcd\_slow\_requests\_enabled) | Enable or disable the etcd slow requests rule | `bool` | `true` | no |
| <a name="input_general_rules_enabled"></a> [general\_rules\_enabled](#input\_general\_rules\_enabled) | Enable or disable the general rules | `bool` | `true` | no |
| <a name="input_grafana_org_id"></a> [grafana\_org\_id](#input\_grafana\_org\_id) | The ID of the Grafana organization | `number` | `1` | no |
| <a name="input_kube_apiserver_availability_rules_enabled"></a> [kube\_apiserver\_availability\_rules\_enabled](#input\_kube\_apiserver\_availability\_rules\_enabled) | Enable or disable the kube-apiserver availability rule | `bool` | `true` | no |
| <a name="input_kube_apiserver_histogram_rules_enabled"></a> [kube\_apiserver\_histogram\_rules\_enabled](#input\_kube\_apiserver\_histogram\_rules\_enabled) | Enable or disable the kube-apiserver histogram rule | `bool` | `true` | no |
| <a name="input_kube_state_metrics_errors_alerts_enabled"></a> [kube\_state\_metrics\_errors\_alerts\_enabled](#input\_kube\_state\_metrics\_errors\_alerts\_enabled) | Enable or disable the kube-state-metrics errors alert rule | `bool` | `true` | no |
| <a name="input_kubernetes_apps_alerts_enabled"></a> [kubernetes\_apps\_alerts\_enabled](#input\_kubernetes\_apps\_alerts\_enabled) | Enable or disable the Kubernetes apps alert rule | `bool` | `true` | no |
| <a name="input_kubernetes_storage_alerts_enabled"></a> [kubernetes\_storage\_alerts\_enabled](#input\_kubernetes\_storage\_alerts\_enabled) | Enable or disable the Kubernetes storage alert rule | `bool` | `true` | no |
| <a name="input_node_exporter_alerts_enabled"></a> [node\_exporter\_alerts\_enabled](#input\_node\_exporter\_alerts\_enabled) | Enable or disable the node filesystem space filling up rule | `bool` | `true` | no |
| <a name="input_node_network_interface_alerts_enabled"></a> [node\_network\_interface\_alerts\_enabled](#input\_node\_network\_interface\_alerts\_enabled) | Enable or disable the node network interface flapping rule | `bool` | `true` | no |
| <a name="input_notification_settings"></a> [notification\_settings](#input\_notification\_settings) | The notification settings for the alerts | <pre>object({<br/>        contact_point = string<br/>        group_by      = list(string)<br/>        mute_timings  = list(string)<br/>    })</pre> | <pre>{<br/>  "contact_point": "team-infrastructure-notifications",<br/>  "group_by": [<br/>    "namespace",<br/>    "pod"<br/>  ],<br/>  "mute_timings": null<br/>}</pre> | no |
| <a name="input_prometheus_alerts_enabled"></a> [prometheus\_alerts\_enabled](#input\_prometheus\_alerts\_enabled) | Enable or disable the Prometheus alerting rule | `bool` | `true` | no |
| <a name="input_prometheus_general_recording_rules_enabled"></a> [prometheus\_general\_recording\_rules\_enabled](#input\_prometheus\_general\_recording\_rules\_enabled) | Enable or disable the Prometheus general recording rule | `bool` | `true` | no |
| <a name="input_prometheus_general_rules_enabled"></a> [prometheus\_general\_rules\_enabled](#input\_prometheus\_general\_rules\_enabled) | Enable or disable the Prometheus general rule | `bool` | `true` | no |
| <a name="input_prometheus_namespace"></a> [prometheus\_namespace](#input\_prometheus\_namespace) | The namespace of the Prometheus instance | `string` | `"prometheus"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_config_reloader_rule_id"></a> [config\_reloader\_rule\_id](#output\_config\_reloader\_rule\_id) | n/a |
| <a name="output_etcd_rule_id"></a> [etcd\_rule\_id](#output\_etcd\_rule\_id) | n/a |
| <a name="output_etcd_rule_slow_query_uid"></a> [etcd\_rule\_slow\_query\_uid](#output\_etcd\_rule\_slow\_query\_uid) | n/a |
<!-- END_TF_DOCS -->
