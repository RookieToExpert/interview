#!/bin/bash
threshold=100  # 单位MB

swap_used=$(free -m | awk '/Swap/{print $3}')
if [ $swap_used -ge $threshold ]; then
  echo "警告：Swap使用超过阈值！当前使用: ${swap_used}MB"
  # 可扩展：发送钉钉/邮件告警
fi
