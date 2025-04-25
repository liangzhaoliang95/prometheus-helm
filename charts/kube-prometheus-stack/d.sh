#!/usr/bin/env bash

cp values.yaml values_temp.yaml

# 将nfs-prom替换为nfs-temp
sed -i 's/nfs-prom/nfs-temp/g' values_temp.yaml

helm upgrade --install rongke-prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace -f values_temp.yaml


rm -rf values_temp.yaml
