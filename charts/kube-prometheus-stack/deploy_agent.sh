#!/usr/bin/env bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
echo "prometheus-community repo added and updated"

cp values_agent.yaml values_temp.yaml

# 将nfs-prom替换为nfs-temp
# 判断如果是macos系统，则使用gsed命令
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i "" 's/P_STORAGE_CLASS_P/nfs-prom/g' values_temp.yaml
  # 调整全局标签集群名称
  sed -i "" 's/P_LABEL_CLUSTER_P/rongke-private/g' values_temp.yaml
else
  sed -i 's/P_STORAGE_CLASS_P/nfs-prom/g' values_temp.yaml
  # 调整全局标签集群名称
  sed -i 's/P_LABEL_CLUSTER_P/rongke-private/g' values_temp.yaml
fi


echo "start installing prometheus agent"

helm upgrade --install rongke-prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace -f values_temp.yaml

echo "prometheus agent installed"

#rm -rf values_temp.yaml
