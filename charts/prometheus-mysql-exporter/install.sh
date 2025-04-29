#!/bin/zsh

cp values.yaml values_temp.yaml

sed -i 's/P_LABEL_CLUSTER_P/rongke-private/g' values_temp.yaml
sed -i 's/P_MYSQL_HOST_P/172.17.3.189/g' values_temp.yaml
sed -i 's/P_MYSQL_PASSWORD_P/11#Plaso1865(*/g' values_temp.yaml

helm upgrade --install rongke-mysql-exporter prometheus-community/prometheus-mysql-exporter \
  --namespace monitoring \
  --create-namespace \
  -f values_temp.yaml

rm -rf values_temp.yaml
