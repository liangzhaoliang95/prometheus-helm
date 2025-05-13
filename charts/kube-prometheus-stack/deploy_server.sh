#!/usr/bin/env bash

storageClass=$1
clusterLabel=$2
version=$3

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

# 判断有无版本
if [ -n "$version" ]; then
  helm upgrade --install rongke-prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace -f values_temp.yaml --version $version
else
  helm upgrade --install rongke-prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace -f values_temp.yaml
fi

# 判断是否安装成功
if [ $? -ne 0 ]; then
  echo "prometheus stack installation failed"
  exit 1
fi

echo "prometheus stack installed"

rm -rf values_temp.yaml

kubectl apply -f ./secrets/prometheus_remote_secrets.yaml -n monitoring

# 如果服务器有jq
if command -v jq &> /dev/null
then
  echo "jq is installed, modifying ServiceMonitor"
  # 对所有集群的服务监控进行修改 添加全局cluster标签
  kubectl get servicemonitor -A -o json | \
    jq '.items[] | .spec.endpoints |= (map(.relabelings = ((.relabelings // []) | map(select(.targetLabel != "cluster")) + [{"targetLabel": "cluster", "replacement": "ecloud"}])))' | \
    kubectl apply -f -
else
  echo "jq is not installed, skipping ServiceMonitor modification"
  # 对中心集群的服务监控进行修改 添加全局cluster标签
  kubectl get servicemonitor -A -o yaml | \
    yq eval '(.items[].spec.endpoints[].relabelings |= (select(. != null) | map(select(.targetLabel != "cluster")) + [{"targetLabel": "cluster", "replacement": "ecloud"}]))' | \
    kubectl apply -f -

fi

