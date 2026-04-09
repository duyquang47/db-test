import json
from copy import deepcopy
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PATHS = [
    ROOT / "modules" / "load-testing" / "charts" / "postgres-dsm-test-stack" / "dashboards" / "postgres-performance-test-metrics-dashboard.json",
    ROOT / "config" / "dashboards" / "postgres-performance-test-metrics-dashboard.json",
]


def stat_panel(panel_id, title, expr, x, y, description="", unit="short", width=3, height=4):
    thresholds = [{"color": "red", "value": None}, {"color": "green", "value": 1}] if unit == "none" else [{"color": "green", "value": None}]
    return {
        "datasource": "$datasource",
        "description": description,
        "fieldConfig": {
            "defaults": {
                "color": {"mode": "thresholds"},
                "decimals": 2,
                "mappings": [],
                "thresholds": {"mode": "absolute", "steps": thresholds},
                "unit": unit,
            },
            "overrides": [],
        },
        "gridPos": {"h": height, "w": width, "x": x, "y": y},
        "id": panel_id,
        "options": {
            "colorMode": "value",
            "graphMode": "area",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {"calcs": ["lastNotNull"], "fields": "", "values": False},
            "textMode": "value_and_name",
        },
        "pluginVersion": "11.1.0",
        "targets": [
            {
                "datasource": "$datasource",
                "editorMode": "code",
                "exemplar": True,
                "expr": expr,
                "instant": True,
                "legendFormat": "",
                "range": False,
                "refId": "A",
            }
        ],
        "title": title,
        "type": "stat",
    }


def timeseries_panel(panel_id, title, targets, x, y, description="", unit="short", width=8, height=8):
    panel_targets = []
    for index, target in enumerate(targets):
        panel_targets.append(
            {
                "datasource": "$datasource",
                "editorMode": "code",
                "expr": target["expr"],
                "legendFormat": target.get("legendFormat", ""),
                "range": True,
                "refId": chr(ord("A") + index),
            }
        )

    return {
        "datasource": "$datasource",
        "description": description,
        "fieldConfig": {
            "defaults": {
                "color": {"mode": "palette-classic"},
                "custom": {
                    "axisCenteredZero": False,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "barAlignment": 0,
                    "drawStyle": "line",
                    "fillOpacity": 10,
                    "gradientMode": "none",
                    "hideFrom": {"legend": False, "tooltip": False, "viz": False},
                    "lineInterpolation": "linear",
                    "lineWidth": 2,
                    "pointSize": 3,
                    "scaleDistribution": {"type": "linear"},
                    "showPoints": "never",
                    "spanNulls": False,
                    "stacking": {"group": "A", "mode": "none"},
                    "thresholdsStyle": {"mode": "off"},
                },
                "mappings": [],
                "thresholds": {"mode": "absolute", "steps": [{"color": "green", "value": None}]},
                "unit": unit,
            },
            "overrides": [],
        },
        "gridPos": {"h": height, "w": width, "x": x, "y": y},
        "id": panel_id,
        "options": {
            "legend": {"calcs": ["lastNotNull", "max"], "displayMode": "table", "placement": "bottom", "showLegend": True},
            "tooltip": {"mode": "multi", "sort": "desc"},
        },
        "pluginVersion": "11.1.0",
        "targets": panel_targets,
        "title": title,
        "type": "timeseries",
    }


def build_db_cluster_panels():
    return [
        stat_panel(
            50,
            "DB Cluster Scrape",
            'max(last_over_time(dsm_db_cluster_scrape_success{target=~"$target",instance=~"$instance"}[$__range]))',
            0,
            49,
            description="Collector health for the DSM DB Kubernetes cluster metrics.",
            unit="none",
        ),
        stat_panel(
            51,
            "DB Nodes",
            'count(dsm_db_node_info{target=~"$target",instance=~"$instance"})',
            3,
            49,
            description="Number of Kubernetes nodes currently hosting the DSM PostgreSQL pods.",
        ),
        stat_panel(
            52,
            "DB Pods",
            'count(dsm_db_pod_info{target=~"$target",instance=~"$instance"})',
            6,
            49,
            description="Number of PostgreSQL and monitor pods discovered in the DSM DB namespace.",
        ),
        stat_panel(
            53,
            "Node CPU Max %",
            'max(last_over_time(dsm_db_node_cpu_utilization_ratio{target=~"$target",instance=~"$instance"}[$__range])) * 100',
            9,
            49,
            description="Highest node CPU utilization across the DB cluster over the selected time range.",
            unit="percent",
        ),
        stat_panel(
            54,
            "Node Memory Max %",
            'max(last_over_time(dsm_db_node_memory_utilization_ratio{target=~"$target",instance=~"$instance"}[$__range])) * 100',
            12,
            49,
            description="Highest node memory utilization across the DB cluster over the selected time range.",
            unit="percent",
        ),
        stat_panel(
            55,
            "Node FS Max %",
            'max(last_over_time(dsm_db_node_fs_utilization_ratio{target=~"$target",instance=~"$instance"}[$__range])) * 100',
            15,
            49,
            description="Highest root filesystem utilization across the DB cluster nodes.",
            unit="percent",
        ),
        stat_panel(
            56,
            "Pod CPU Max",
            'max(last_over_time(dsm_db_pod_cpu_usage_cores{target=~"$target",instance=~"$instance"}[$__range]))',
            18,
            49,
            description="Peak PostgreSQL pod CPU usage in cores.",
            unit="cores",
        ),
        stat_panel(
            57,
            "Pod Memory Max",
            'max(last_over_time(dsm_db_pod_memory_usage_bytes{target=~"$target",instance=~"$instance"}[$__range]))',
            21,
            49,
            description="Peak PostgreSQL pod memory usage over the selected time range.",
            unit="bytes",
        ),
        timeseries_panel(
            58,
            "DB Node CPU Utilization %",
            [
                {
                    "expr": 'dsm_db_node_cpu_utilization_ratio{target=~"$target",instance=~"$instance"} * 100',
                    "legendFormat": "{{node}}",
                }
            ],
            0,
            53,
            description="CPU utilization per DB node derived from the kubelet summary API.",
            unit="percent",
        ),
        timeseries_panel(
            59,
            "DB Node Memory Utilization %",
            [
                {
                    "expr": 'dsm_db_node_memory_utilization_ratio{target=~"$target",instance=~"$instance"} * 100',
                    "legendFormat": "{{node}}",
                }
            ],
            8,
            53,
            description="Memory utilization per DB node derived from the kubelet summary API.",
            unit="percent",
        ),
        timeseries_panel(
            60,
            "DB Pod CPU Usage",
            [
                {
                    "expr": 'sum by (pod, role) (dsm_db_pod_cpu_usage_cores{target=~"$target",instance=~"$instance"})',
                    "legendFormat": "{{pod}} ({{role}})",
                }
            ],
            16,
            53,
            description="CPU usage per PostgreSQL/monitor pod from metrics.k8s.io.",
            unit="cores",
        ),
        timeseries_panel(
            61,
            "DB Node FS Utilization %",
            [
                {
                    "expr": 'dsm_db_node_fs_utilization_ratio{target=~"$target",instance=~"$instance"} * 100',
                    "legendFormat": "{{node}}",
                }
            ],
            0,
            61,
            description="Root filesystem utilization on the nodes that host the DSM DB pods.",
            unit="percent",
        ),
        timeseries_panel(
            62,
            "DB Node Network Throughput",
            [
                {
                    "expr": 'rate(dsm_db_node_network_rx_bytes_total{target=~"$target",instance=~"$instance"}[5m])',
                    "legendFormat": "{{node}} rx",
                },
                {
                    "expr": 'rate(dsm_db_node_network_tx_bytes_total{target=~"$target",instance=~"$instance"}[5m])',
                    "legendFormat": "{{node}} tx",
                },
            ],
            8,
            61,
            description="Aggregate receive and transmit throughput per DB node.",
            unit="Bps",
        ),
        timeseries_panel(
            63,
            "DB Pod Memory Usage",
            [
                {
                    "expr": 'sum by (pod, role) (dsm_db_pod_memory_usage_bytes{target=~"$target",instance=~"$instance"})',
                    "legendFormat": "{{pod}} ({{role}})",
                }
            ],
            16,
            61,
            description="Memory usage per PostgreSQL/monitor pod from metrics.k8s.io.",
            unit="bytes",
        ),
    ]


def update_dashboard(path):
    data = json.loads(path.read_text(encoding="utf-8-sig"))
    existing_ids_to_replace = set(range(50, 64))
    legacy_placeholder_present = any(panel.get("id") == 30 for panel in data["panels"])
    updated_panels = []
    for panel in data["panels"]:
        if panel.get("id") in existing_ids_to_replace:
            continue
        if panel.get("id") == 29:
            panel = deepcopy(panel)
            panel["title"] = "DSM DB Cluster OS Metrics"
            updated_panels.append(panel)
        elif panel.get("id") == 30:
            continue
        else:
            if legacy_placeholder_present and panel.get("id", 0) >= 31:
                panel = deepcopy(panel)
                panel["gridPos"]["y"] = panel["gridPos"]["y"] + 15
            updated_panels.append(panel)

    updated_panels.extend(build_db_cluster_panels())
    updated_panels.sort(key=lambda panel: (panel["gridPos"]["y"], panel["gridPos"]["x"], panel["id"]))
    data["panels"] = updated_panels
    path.write_text(json.dumps(data, ensure_ascii=False, indent=4) + "\n", encoding="utf-8-sig")


for dashboard_path in PATHS:
    update_dashboard(dashboard_path)
    print(f"Updated {dashboard_path}")
