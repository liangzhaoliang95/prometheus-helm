#!/usr/bin/env bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
echo "prometheus-community repo added and updated"

cp values_agent.yaml values_temp.yaml

# 将nfs-prom替换为nfs-temp
sed -i 's/nfs-prom/nfs-prom/g' values_temp.yaml
# 调整全局标签集群名称
sed -i 's/lxz/rongke-private/g' values_temp.yaml

echo "start installing prometheus agent"

helm upgrade --install rongke-prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace -f values_temp.yaml

echo "prometheus agent installed"

#rm -rf values_temp.yaml
