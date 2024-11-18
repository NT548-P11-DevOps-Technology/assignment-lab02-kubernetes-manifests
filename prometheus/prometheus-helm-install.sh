#!/bin/bash

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update prometheus-community
helm install --namespace monitoring prometheus-stack -f values.yml prometheus-community/kube-prometheus-stack --create-namespace
