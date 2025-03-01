#!/bin/bash
interval=2  # 刷新间隔

echo "监控磁盘IO (按 Ctrl+C 退出):"
iostat -dxm $interval | awk '
  /Device/ { header=1 }
  header && !/^$/ { 
    print "设备:", $1, "IO使用率:", $14"%, 平均等待:", $10"ms, 吞吐量:", $5"MB/s"
  }
'
