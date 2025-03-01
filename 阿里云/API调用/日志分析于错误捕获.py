import re
from collections import defaultdict

def analyze_nginx_errors(log_file):
    error_counts = defaultdict(int)
    with open(log_file, 'r') as f:
        for line in f:
            # 匹配5xx错误，如 "127.0.0.1 - - [10/Sep/2023:14:32:01 +0800] "GET /api HTTP/1.1" 500 612"
            match = re.search(r'" (\d{3}) \d+', line)
            if match and match.group(1).startswith('5'):
                status_code = match.group(1)
                error_counts[status_code] += 1
    return error_counts

# 输出结果并触发告警
errors = analyze_nginx_errors('/var/log/nginx/access.log')
if errors:
    print(f"发现5xx错误: {dict(errors)}")
    # 调用钉钉机器人API发送告警
