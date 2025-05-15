#!/usr/bin/env bash

storageClass=$1 # nfs-prom
clusterLabel=$2 # rongke-lxz
remoteWrite=$3 # https://rongke-prometheus.plaso.cn
version=$4 # 38.0.3

helm repo add prometheus-community https://helm.geekz.cn:81/prometheus-community/helm-charts
helm repo update
echo "prometheus-community repo added and updated"

cp values_agent.yaml values_temp.yaml

# 将nfs-prom替换为nfs-temp
# 判断如果是macos系统，则使用gsed命令
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i "" "s|P_STORAGE_CLASS_P|$storageClass|g" values_temp.yaml
  # 调整全局标签集群名称
  sed -i "" "s|P_LABEL_CLUSTER_P|$clusterLabel|g" values_temp.yaml
  # 远程写入地址
  sed -i "" "s|P_REMOTE_WRITE_P|$remoteWrite|g" values_temp.yaml
else
  sed -i "s|P_STORAGE_CLASS_P|$storageClass|g" values_temp.yaml
  # 调整全局标签集群名称
  sed -i "s|P_LABEL_CLUSTER_P|$clusterLabel|g" values_temp.yaml
  # 远程写入地址
  sed -i "s|P_REMOTE_WRITE_P|$remoteWrite|g" values_temp.yaml
fi

echo "start installing prometheus agent"

# 判断有无版本
if [ -n "$version" ]; then
  helm upgrade --install rongke-prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace -f values_temp.yaml --version $version
else
  helm upgrade --install rongke-prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace -f values_temp.yaml
fi

# 判断是否安装成功
if [ $? -ne 0 ]; then
  echo "prometheus agent installation failed"
  exit 1
fi


echo "prometheus agent installed"

rm -rf values_temp.yaml

kubectl apply -f ./secrets/prometheus_remote_secrets.yaml -n monitoring
