#!/usr/bin/env bash

storageClass=$1
clusterLabel=$2

helm repo add prometheus-community https://helm.geekz.cn:81/prometheus-community/helm-charts
helm repo update
echo "prometheus-community repo added and updated"

cp values_server.yaml values_temp.yaml

# 将nfs-prom替换为nfs-temp
# 判断如果是macos系统，则使用gsed命令
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i "" "s/P_STORAGE_CLASS_P/$storageClass/g" values_temp.yaml
  # 调整全局标签集群名称
  sed -i "" "s/P_LABEL_CLUSTER_P/$clusterLabel/g" values_temp.yaml
else
  sed -i "s/P_STORAGE_CLASS_P/$storageClass/g" values_temp.yaml
  # 调整全局标签集群名称
  sed -i "s/P_LABEL_CLUSTER_P/$clusterLabel/g" values_temp.yaml
fi

echo "start installing prometheus stack"

helm upgrade --install rongke-prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace -f values_temp.yaml --version 38.0.3

echo "prometheus stack installed"

rm -rf values_temp.yaml

# 对中心集群的服务监控进行修改 添加全局cluster标签
kubectl get servicemonitor -A -o yaml | \
  yq eval '(.items[].spec.endpoints[].relabelings |= (select(. != null) | map(select(.targetLabel != "cluster")) + [{"targetLabel": "cluster", "replacement": "ecloud"}]))' | \
  kubectl apply -f -
