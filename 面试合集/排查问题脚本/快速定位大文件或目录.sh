#!/bin/bash
dir="/var"          # 搜索目录
top_n=10            # 显示前N个大文件
min_size="+100M"    # 最小文件大小

echo "查找目录 $dir 中大于${min_size}的文件:"
find $dir -type f -size $min_size -exec du -h {} + | sort -rh | head -n $top_n
