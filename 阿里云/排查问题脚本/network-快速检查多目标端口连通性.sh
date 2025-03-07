#!/bin/bash
# Program:
#       快速测试到特定主机的特定端口的连通性
# History:
# 2024/8/8    Ray    First release
# 定义需要测试的主机名和端口，以下只是例子：
targets=(
  "login.microsoft.com:443"
  "rayrayray.blob.storage.azure.net:443"
  "10.0.0.1:8080"
)
# 使用前，请确保客户有安装好对应的测试工具，如以下nc，telnet，timeout等
for target in "${targets[@]}"; do
  host=${target%:*}
  port=${target#*:}
  # 使用nc测试端口，超时2秒
  echo "NC test result-------------------------"
  if nc -zv -w2 $host $port &>/dev/null; then
    echo "[OK] $host:$port connected"
  else
    echo "[FAIL] $host:$port not connected"
  fi
  echo "telnet test result---------------------"
  if timeout 2 telnet $host $port &>/dev/null; then
    echo "[OK] $host:$port connected"
  else
    echo "[FAIL] $host:$port not connected"
  fi
  ## 如果有其他测试工具，可以根据上面模板继续添加
done
