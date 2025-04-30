#!/bin/zsh

cp values.yaml values_temp.yaml

sed -i 's/P_LABEL_CLUSTER_P/lxz/g' values_temp.yaml
sed -i 's/P_MYSQL_HOST_P/192.168.0.228/g' values_temp.yaml
sed -i 's/P_MYSQL_USER_P/root/g' values_temp.yaml
sed -i 's/P_MYSQL_PASSWORD_P/gXbg01N^ixRm%*6/g' values_temp.yaml
sed -i 's/P_MYSQL_PORT_P/13049/g' values_temp.yaml

helm upgrade --install rongke-mysql-exporter prometheus-community/prometheus-mysql-exporter \
  --namespace monitoring \
  --create-namespace \
  -f values_temp.yaml

rm -rf values_temp.yaml
