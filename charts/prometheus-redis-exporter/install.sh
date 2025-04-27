#!/bin/zsh
helm upgrade --install rongke-redis-exporter prometheus-community/prometheus-redis-exporter \
  --namespace monitoring \
  --create-namespace \
  -f values.yaml