客户是在本地自建的k8s集群，集群通过kubeadm部署，有5个命名空间，其中两个是业务系统(订单系统和客户服务系统)，剩下的是测试和监控等。K8s版本是1.26，我们Arc注册时需要升级。
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
    --use-restic
```
设置备份主体和备份频率，编写相关的YAML文件：
备份主体：
```yaml
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: daily-backup-orders
  namespace: velero
spec:
  includedNamespaces:
  - orders
  - payments
  includedResources:
  - deployments
  - statefulsets
  - persistentvolumeclaims
  - secrets
  snapshotVolumes: true
  ttl: 720h0m0s  # 保留 30 天
  storageLocation: default
```
编写备份频率的yaml文件：
```yaml
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: daily-backup
  namespace: velero
spec:
  schedule: "0 2 * * *"  # 每天凌晨2点，Cron表达式
  template:
    ttl: 168h0m0s  # 每个备份保留 7 天
    includedNamespaces:
    - orders
    - payments
    snapshotVolumes: true
```
然后执行yaml文件：
```yaml
kubectl apply -f daily-schedule.yaml
```
可以通过velero查看计划和备份记录以及恢复：
```velero
velero get schedules
velero get backups
velero restore create --from-backup daily-backup-20240719
```
**遇到restic容器没权限的问题，通过PodSecurityPolicy或者设置hostPID: true.**
恢复目标希望是在本地恢复，但是也能够接受恢复到另一台新集群。
没有做过恢复演练，可以集成GitOps。
数据加密需要全程加密TLS 1.2及以上，存储端使用Azure Blob的SSE + CMK加密。
希望通过key vault管理密钥，权限通过RBAC审批。数据中包含金融交易记录，需要启用Blob的blob versioning或不可篡改策略。
希望备份数据可以复制一份到另一个azure region，保证备份数据的高可用。
本地集群无法直接访问公网，只能通过expressroute或私有通道。
不提供k8s集群的admin账户，但可以通过azure arc注入权限，备份状态和失败情况也希望能够推送到azure monitor和log analytics中。
