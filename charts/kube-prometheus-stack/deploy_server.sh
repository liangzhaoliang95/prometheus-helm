#!/usr/bin/env bash

helm repo add prometheus-community https://helm.geekz.cn:81/repository/helm-proxy
helm repo update
echo "prometheus-community repo added and updated"

cp values.yaml values_temp.yaml

# 将nfs-prom替换为nfs-temp
sed -i 's/nfs-prom/nfs-temp/g' values_temp.yaml
# 调整全局标签集群名称
sed -i 's/lxz/lxz/g' values_temp.yaml

echo "start installing prometheus stack"

helm upgrade --install rongke-prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace -f values_temp.yaml

echo "prometheus stack installed"

rm -rf values_temp.yaml
