#!/bin/bash
targets=("aliyun-oss.cn-hangzhou.aliyuncs.com:443" "rds.aliyuncs.com:3306")
for target in "${targets[@]}"; do
    host=$(echo $target | cut -d: -f1)
    port=$(echo $target | cut -d: -f2)
    # 测试端口连通性
    nc -zv $host $port &>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ $host:$port 连通正常"
    else
        echo "❌ $host:$port 无法连接"
        # 附加诊断：DNS解析和路由跟踪
        dig $host +short
        traceroute $host
    fi
done
