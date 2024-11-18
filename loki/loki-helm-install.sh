#!/bin/bash

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update grafana
helm install loki grafana/loki --namespace loki --version 6.16.0 -f values.yml 
