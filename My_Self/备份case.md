客户是在本地自建的k8s集群，集群通过kubeadm部署，有5个命名空间，其中两个是业务系统(订单系统和客户服务系统)，剩下的是测试和监控等。K8s版本是1.26。
希望备份业务相关的两个命名空间，希望备份的内容是所有YAML对象资源(deployment, service, configmag, secret等)，所有持久化数据卷(PVC, NFS后端等)。
集群中有运行PostgreSQL和Redis，都以StatefulSet 方式部署。Redis 有持久化，Postgres 数据存在 PVC 中。文件上传也存在NFS的挂载卷里，也需要备份。
关于RPO要求小于30分钟，RTO一小时内，希望支持namespace，单个工作负载，PVC粒度恢复。
**我们在本地集群中部署Azure Arc Agent，注册集群到ARM，启用resource group管理，然后创建一个azure storage account，并且启用GRS备份冗余作为备份数据，启用cmk加密，通过key vault绑定，并且根据客户要求数据中包含金融交易记录，
启用Blob的blob versioning和不可篡改策略，在本地集群中部署Velero控制器，配置azure plugin制定备份目标为blob storage，使用storage access key。**

## 安装Velero
帮助客户在本地部署Velero，需要提前准备好Azure存储账户，access key等认证文件。
```bash
velero install \
    --provider azure \
    --plugins velero/velero-plugin-for-microsoft-azure:v1.6.0 \
    --bucket <your-bucket-name> \
    --secret-file ./credentials-velero \
    --backup-location-config resourceGroup=<your-rg>,storageAccount=<your-sa>,subscriptionId=<your-sub-id> \
    --use-volume-snapshots=false \

velero install \
  --provider azure \
  --plugins velero/velero-plugin-for-microsoft-azure:v1.7.0 \
  --bucket velero \
  --secret-file ./credentials-velero \
  --use-volume-snapshots=true \
  --backup-location-config resourceGroup=...,storageAccount=...,subscriptionId=... \
  --volume-snapshot-location-config resourceGroup=<your-disk-rg>,subscriptionId=<your-sub-id>
```

## 编写一次性手动备份的YAML文件：
备份主体：
```yaml
# manual-backup.yaml
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: manual-backup
  namespace: velero
spec:
  includedNamespaces:
  - order-system
  - customer-system
  includedResources:
  - deployments
  - services
  - configmaps
  - secrets
  - persistentvolumeclaims
  defaultVolumesToRestic: true
  ttl: 72h
```

**执行on-demand backup:**
```kubectl
kubectl apply -f daily-backup-schedule.yaml
```

## 编写自动备份的yaml文件：
```yaml
# daily-backup-schedule.yaml
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: daily-backup
  namespace: velero
spec:
  schedule: "*/30 * * * *"  # 每 30 分钟一次，满足 RPO
  template:
    includedNamespaces:
    - order-system
    - customer-system
    ttl: 168h  # 保留 7 天
    defaultVolumesToRestic: true
    includedResources:
    - deployments
    - services
    - configmaps
    - secrets
    - persistentvolumeclaims
```
**然后执行yaml文件：**
```yaml
kubectl apply -f daily-schedule.yaml
```

**可以通过velero查看计划和备份记录以及恢复：**
```velero
velero get schedules
velero get backups
velero restore create --from-backup daily-backup-20240719
```

## 遇到网络问题，无法连接blobPE
数据加密需要全程加密TLS 1.2及以上，存储端使用Azure Blob的SSE + CMK加密，客户K8S宿主机没有public IP，本地网络架构靠一台NVA作为出站流量，客户已经配置了express route到VNET1，目前storage account的private endpoint在VNET2，通过Vnet peering去解决连通问题，我们是通过private dns resolver去解决解析问题。
希望通过key vault管理密钥，权限通过RBAC审批。数据中包含金融交易记录，需要启用Blob的blob versioning或不可篡改策略。
可以通过kubectl logs deployment/velero -n velero去查看velero的报错

恢复目标希望是在本地恢复，但是也能够接受恢复到另一台新集群。

希望备份数据可以复制一份到另一个azure region，保证备份数据的高可用。
本地集群无法直接访问公网，只能通过expressroute或私有通道。

