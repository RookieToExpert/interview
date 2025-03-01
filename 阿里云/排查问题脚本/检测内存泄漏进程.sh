#!/bin/bash
# 每隔5秒记录一次进程内存，输出增长趋势
interval=5
count=3

echo "监控进程内存变化（单位MB）:"
for i in $(seq 1 $count); do
  echo "===== 第$i次采样 ====="
  ps -eo pid,rss,comm | awk '{printf "%-10s %-10s %-10s\n", $1, $2/1024, $3}' | sort -k2 -n | tail -n 5
  sleep $interval
done

# ===== 第1次采样 =====
# PID        RSS(MB)    COMMAND
# 1234       256.7      java
# ===== 第2次采样 =====
# 1234       312.5      java  # 发现内存持续增长
