#!/usr/bin/env bash
env=$1
rsync -arv \
    --rsync-path="mkdir -p ~/project/prometheus && rsync" \
    --exclude /private/front/*/ \
    --exclude /node_modules/ \
    --exclude /serverscript/conf/ \
    --exclude /k8s/kustomize/plugin_mac_darwin/ \
    --exclude /k8s/kustomize/config/ecloud-*/ \
    --exclude /k8s/kustomize/config/rk-*/ \
    --exclude /k8s/kustomize/config/rongke-*/ \
    --exclude /k8s/kustomize/config/infi-*-www/ \
    --exclude={.idea,.git,test,node_modules} \
    ./ \
    root@$env:~/project/prometheus
