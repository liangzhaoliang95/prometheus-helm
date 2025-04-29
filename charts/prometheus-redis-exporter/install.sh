#!/bin/zsh

cp values.yaml values_temp.yaml

sed -i 's/P_LABEL_CLUSTER_P/rongke-private/g' values_temp.yaml
sed -i 's/P_REDIS_HOST_P/172.17.3.189/g' values_temp.yaml
sed -i 's/P_REDIS_PASSWORD_P/11#Plaso1865(*/g' values_temp.yaml

helm upgrade --install rongke-redis-exporter prometheus-community/prometheus-redis-exporter \
  --namespace monitoring \
  --create-namespace \
  -f values_temp.yaml

rm -rf values_temp.yaml
