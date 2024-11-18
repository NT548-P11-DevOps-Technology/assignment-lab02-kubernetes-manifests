#!/bin/bash

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update grafana
helm install promtail grafana/promtail --namespace loki -f values.yml
