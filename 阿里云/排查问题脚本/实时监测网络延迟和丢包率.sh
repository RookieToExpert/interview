#!/bin/bash
target_ip="223.5.5.5"  # 阿里云DNS
interval=10            # 每10秒测试一次

while true; do
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  ping_result=$(ping -c 4 $target_ip | tail -2)
  echo "[$timestamp] $ping_result"
  sleep $interval
done
