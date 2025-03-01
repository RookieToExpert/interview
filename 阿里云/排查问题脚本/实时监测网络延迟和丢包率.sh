#!/bin/bash
target_ip="223.5.5.5"  # 阿里云DNS
interval=10            # 每10秒测试一次

while true; do
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  ping_result=$(ping -c 4 $target_ip | tail -2)
  echo "[$timestamp] $ping_result"
  sleep $interval
done

# [2023-09-10 14:00:00] 4 packets transmitted, 4 received, 0% packet loss, time 3004ms rtt min/avg/max/mdev = 10.123/12.456/15.789/2.123 ms
