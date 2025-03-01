#!/bin/bash
# 本地镜像列表
images=("nginx:1.21" "my-app:latest")

# 阿里云ACR地址
acr_registry="registry.cn-hangzhou.aliyuncs.com/my-namespace"

for image in "${images[@]}"; do
    # 拉取本地镜像
    docker pull $image
    # 重新打标签
    new_tag="${acr_registry}/${image}"
    docker tag $image $new_tag
    # 推送至ACR
    docker push $new_tag
done
