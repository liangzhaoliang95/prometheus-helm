#!/bin/zsh
helm upgrade --install rongke-mysql-exporter prometheus-community/prometheus-mysql-exporter \
  --namespace monitoring \
  --create-namespace \
  -f values.yaml