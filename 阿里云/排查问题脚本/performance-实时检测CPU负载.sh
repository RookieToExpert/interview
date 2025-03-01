#!/bin/bash
interval=5  # 5秒刷新一次

while true; do
  clear
  echo "====== CPU负载监控 ======"
  echo "整体使用率:"
  top -bn1 | grep "%Cpu(s)"
  echo -e "\n占用CPU前5进程:"
  ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6
  sleep $interval
done
