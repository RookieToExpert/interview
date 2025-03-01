#!/bin/bash
# 获取所有异常Pod
kubectl get pods --all-namespaces -o json | \
jq -r '.items[] | select(.status.phase != "Running" and .status.phase != "Succeeded") | "\(.metadata.namespace) \(.metadata.name) \(.status.phase) \(.status.reason)"'

# 输出示例：
# default web-app-1 CrashLoopBackOff Container restarting
