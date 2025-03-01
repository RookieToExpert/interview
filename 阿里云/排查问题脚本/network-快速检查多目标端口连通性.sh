#!/bin/bash
# 定义目标主机和端口列表
targets=(
  "aliyun.com:80"
  "rds.aliyuncs.com:3306"
  "10.0.0.1:22"
)

for target in "${targets[@]}"; do
  host=${target%:*}
  port=${target#*:}
  # 使用nc测试端口，超时2秒
  if nc -zv -w2 $host $port &>/dev/null; then
    echo "[OK] $host:$port 连通正常"
  else
    echo "[FAIL] $host:$port 无法连接"
  fi
done
