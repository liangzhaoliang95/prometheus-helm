#!/bin/zsh

docker run -d \
  --name=node-exporter \
  --net=host \
  --pid=host \
  --privileged \
  -v "/:/host:ro,rslave" \
  -v "/sys:/host/sys:ro" \
  -v "/proc:/host/proc:ro" \
  --restart=unless-stopped \
  docker-proxy-quay.geekz.cn:81/prometheus/node-exporter \
  --path.rootfs=/host
