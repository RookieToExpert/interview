#!/bin/bash
echo "====== 系统健康检查报告 ======"
echo "- 当前时间: $(date)"
echo "- 负载平均: $(uptime | awk -F 'average:' '{print $2}')"
echo "- 内存使用:"
free -h | awk '/Mem/{printf "总内存: %s 已用: %s 剩余: %s\n", $2, $3, $4}'
echo "- 磁盘使用:"
df -h | grep -v tmpfs
echo "- 占用CPU前3进程:"
ps -eo pid,comm,%cpu --sort=-%cpu | head -n 4
echo "- 占用内存前3进程:"
ps -eo pid,comm,%mem --sort=-%mem | head -n 4

# ====== 系统健康检查报告 ======
# - 当前时间: Wed Sep 10 14:00:00 CST 2023
# - 负载平均: 0.01, 0.05, 0.10
# - 内存使用:
# 总内存: 7.6G 已用: 2.1G 剩余: 5.5G
# - 磁盘使用:
# /dev/vda1  50G  20G   30G  40% /
# - 占用CPU前3进程:
# PID COMMAND         %CPU
# 123 nginx           5.0
# - 占用内存前3进程:
# PID COMMAND         %MEM
# 456 java            12.3
