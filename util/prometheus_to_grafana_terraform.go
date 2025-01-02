package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"log"

	"gopkg.in/yaml.v2"
)

type PrometheusRule struct {
	Groups []struct {
		Name  string `yaml:"name"`
		Rules []struct {
			Expr   string `yaml:"expr"`
			Record string `yaml:"record"`
		} `yaml:"rules"`
	} `yaml:"groups"`
}

type GrafanaRuleGroup struct {
	Name            string `json:"name"`
	FolderUID       string `json:"folder_uid"`
	IntervalSeconds string `json:"interval_seconds"`
	Rules           []Rule `json:"rule"`
}

type Rule struct {
	Name                 string                 `json:"name"`
	Condition            string                 `json:"condition"`
	Annotations          map[string]string      `json:"annotations"`
	NotificationSettings map[string]interface{} `json:"notification_settings"`
	Data                 []Data                 `json:"data"`
}

type Data struct {
	RefID         string                 `json:"ref_id"`
	DatasourceUID string                 `json:"datasource_uid"`
	Model         map[string]interface{} `json:"model"`
	RelativeTime  map[string]int         `json:"relative_time_range"`
}

func main() {
	// Parse CLI arguments
	inputFile := flag.String("input", "", "Path to the input YAML file containing Prometheus rules")
	outputFile := flag.String("output", "", "Path to the output Terraform file. Leave empty to print to stdout.")
	folderUID := flag.String("folder_uid", "grafana_folder.prometheus_alerts.uid", "Folder UID for Grafana rule groups")
	alertInterval := flag.String("interval_seconds", "var.alert_interval_seconds", "Alert interval seconds for Grafana rules")
	flag.Parse()

	if *inputFile == "" {
		log.Fatal("Input file path must be provided")
	}

	// Read YAML file
	data, err := ioutil.ReadFile(*inputFile)
	if err != nil {
		log.Fatalf("Failed to read input file: %v", err)
	}

	// Parse YAML
	var promRules PrometheusRule
	err = yaml.Unmarshal(data, &promRules)
	if err != nil {
		log.Fatalf("Failed to parse YAML: %v", err)
	}

	// Convert to Grafana rule groups
	var grafanaGroups []GrafanaRuleGroup
	for _, group := range promRules.Groups {
		gGroup := GrafanaRuleGroup{
			Name:            group.Name,
			FolderUID:       *folderUID,
			IntervalSeconds: *alertInterval,
		}

		for _, rule := range group.Rules {
			gRule := Rule{
				Name:      rule.Record,
				Condition: "C",
				Annotations: map[string]string{
					"description": fmt.Sprintf("Rule for %s", rule.Record),
				},
				NotificationSettings: map[string]interface{}{
					"contact_point": "var.notification_settings.contact_point",
					"mute_timings":  "var.notification_settings.mute_timings",
				},
				Data: []Data{
					{
						RefID:         "A",
						DatasourceUID: "var.datasource_uid",
						Model: map[string]interface{}{
							"expr":    rule.Expr,
							"refId":   "A",
							"instant": true,
						},
						RelativeTime: map[string]int{
							"from": 300,
							"to":   0,
						},
					},
				},
			}
			gGroup.Rules = append(gGroup.Rules, gRule)
		}
		grafanaGroups = append(grafanaGroups, gGroup)
	}

	// Serialize to JSON
	output, err := json.MarshalIndent(grafanaGroups, "", "  ")
	if err != nil {
		log.Fatalf("Failed to serialize to JSON: %v", err)
	}

	// Write to output or print to stdout
	if *outputFile != "" {
		err = ioutil.WriteFile(*outputFile, output, 0644)
		if err != nil {
			log.Fatalf("Failed to write output file: %v", err)
		}
		fmt.Printf("Successfully translated Prometheus rules to Terraform Grafana rules in %s\n", *outputFile)
	} else {
		fmt.Println(string(output))
	}
}
