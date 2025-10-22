#!/bin/zsh

# bash install.sh -h 172.17.3.189 -p "mypassword" -c rongke-private -n monitoring -r rongke-mysql-exporter

# 默认值
# bash install.sh -h 10.115.0.143 -p "11#Plaso1865(*" -c rongke-gcjyj
CLUSTER_LABEL="rongke-private"
MYSQL_HOST=""
MYSQL_USER="root"
MYSQL_PASSWORD=""
MYSQL_PORT="3306"
RELEASE_NAME="rongke-mysql-exporter"
NAMESPACE="monitoring"

# 帮助信息
function show_help() {
    cat << EOF
使用方法: $0 [选项]

部署 Prometheus MySQL Exporter 到 Kubernetes 集群

必需参数:
    -h, --host HOST          MySQL 服务器地址
    -p, --password PASSWORD  MySQL 密码

可选参数:
    -c, --cluster CLUSTER    集群标签 (默认: $CLUSTER_LABEL)
    -u, --user USER          MySQL 用户名 (默认: $MYSQL_USER)
    -P, --port PORT          MySQL 端口 (默认: $MYSQL_PORT)
    -n, --namespace NS       Kubernetes 命名空间 (默认: $NAMESPACE)
    -r, --release RELEASE    Helm release 名称 (默认: $RELEASE_NAME)
    --help                   显示此帮助信息

示例:
    $0 -h 172.17.3.189 -p "mypassword"
    $0 --host 172.17.3.189 --user root --password "mypassword" --port 3306
    $0 -h 172.17.3.189 -p "mypassword" -c prod-cluster -n monitoring

EOF
    exit 0
}

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--host)
            MYSQL_HOST="$2"
            shift 2
            ;;
        -u|--user)
            MYSQL_USER="$2"
            shift 2
            ;;
        -p|--password)
            MYSQL_PASSWORD="$2"
            shift 2
            ;;
        -P|--port)
            MYSQL_PORT="$2"
            shift 2
            ;;
        -c|--cluster)
            CLUSTER_LABEL="$2"
            shift 2
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -r|--release)
            RELEASE_NAME="$2"
            shift 2
            ;;
        --help)
            show_help
            ;;
        *)
            echo "错误: 未知参数 '$1'"
            echo "使用 '$0 --help' 查看帮助信息"
            exit 1
            ;;
    esac
done

# 验证必需参数
if [[ -z "$MYSQL_HOST" ]]; then
    echo "错误: 必须提供 MySQL 主机地址 (-h 或 --host)"
    echo "使用 '$0 --help' 查看帮助信息"
    exit 1
fi

if [[ -z "$MYSQL_PASSWORD" ]]; then
    echo "错误: 必须提供 MySQL 密码 (-p 或 --password)"
    echo "使用 '$0 --help' 查看帮助信息"
    exit 1
fi

# 显示配置信息
echo "========================================"
echo "部署配置:"
echo "  集群标签: $CLUSTER_LABEL"
echo "  MySQL 主机: $MYSQL_HOST"
echo "  MySQL 用户: $MYSQL_USER"
echo "  MySQL 端口: $MYSQL_PORT"
echo "  Release 名称: $RELEASE_NAME"
echo "  命名空间: $NAMESPACE"
echo "========================================"

# 创建临时配置文件
TEMP_VALUES="values_temp_$(date +%s).yaml"

cp values.yaml "$TEMP_VALUES"

# 替换配置参数
sed -i '' "s/P_LABEL_CLUSTER_P/${CLUSTER_LABEL}/g" "$TEMP_VALUES"
sed -i '' "s/P_MYSQL_HOST_P/${MYSQL_HOST}/g" "$TEMP_VALUES"
sed -i '' "s/P_MYSQL_USER_P/${MYSQL_USER}/g" "$TEMP_VALUES"
# 转义密码中的特殊字符
ESCAPED_PASSWORD=$(echo "$MYSQL_PASSWORD" | sed 's/[&/\]/\\&/g')
sed -i '' "s/P_MYSQL_PASSWORD_P/${ESCAPED_PASSWORD}/g" "$TEMP_VALUES"
sed -i '' "s/P_MYSQL_PORT_P/${MYSQL_PORT}/g" "$TEMP_VALUES"

echo "TEMP_VALUES: $TEMP_VALUES"

# 执行 Helm 安装
echo ""
echo "正在部署 MySQL Exporter..."
helm upgrade --install "$RELEASE_NAME" prometheus-community/prometheus-mysql-exporter \
  --namespace "$NAMESPACE" \
  --create-namespace \
  -f "$TEMP_VALUES"

HELM_EXIT_CODE=$?

# 清理临时文件
rm -f "$TEMP_VALUES"

# 检查部署结果
if [[ $HELM_EXIT_CODE -eq 0 ]]; then
    echo ""
    echo "✓ 部署成功！"
    echo ""
    echo "查看部署状态:"
    echo "  kubectl get pods -n $NAMESPACE -l app.kubernetes.io/instance=$RELEASE_NAME"
else
    echo ""
    echo "✗ 部署失败！"
    exit $HELM_EXIT_CODE
fi
