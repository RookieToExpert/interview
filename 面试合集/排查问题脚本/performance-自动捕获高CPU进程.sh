#!/bin/bash
threshold=80  # CPU%阈值
log_file="/tmp/high_cpu.log"

while true; do
  # 获取CPU超过阈值的进程
  high_cpu=$(ps -eo pid,comm,%cpu --sort=-%cpu | awk -v th=$threshold '$3 > th')
  if [ -n "$high_cpu" ]; then
    echo "[$(date)] 发现高CPU进程:" >> $log_file
    echo "$high_cpu" >> $log_file
  fi
  sleep 30
done
