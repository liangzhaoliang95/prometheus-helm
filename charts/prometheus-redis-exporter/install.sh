#!/bin/zsh

cp values.yaml values_temp.yaml

sed -i 's/P_LABEL_CLUSTER_P/rongke-private/g' values_temp.yaml
sed -i 's/P_REDIS_HOST_P/172.17.3.213/g' values_temp.yaml
sed -i 's/P_REDIS_PASSWORD_P/kVf1Zqf1vf8IN8M/g' values_temp.yaml

helm upgrade --install rongke-redis-exporter prometheus-community/prometheus-redis-exporter \
  --namespace monitoring \
  --create-namespace \
  -f values_temp.yaml

rm -rf values_temp.yaml
