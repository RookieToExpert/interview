#!/bin/bash
# 导出指定命名空间下的所有Deployment
namespace="default"
kubectl get deployments -n $namespace -o yaml > deployments.yaml

# 修改yaml中的镜像地址（如替换为ACR地址）
sed -i 's/old-registry.com/new-registry.aliyuncs.com/g' deployments.yaml

# 在ACK集群中重新部署
kubectl apply -f deployments.yaml
