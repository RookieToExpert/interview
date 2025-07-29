## 背景

客户当前共计部署 13 台 VM，全部运行在 本地 VMware vSphere 环境 中，包括：

前端服务（3 台）：部署 Nginx + React SSR，负责用户页面展示与首屏加载；

API 服务与订单处理（6 台）：负责核心交易、库存验证、支付对接等；

推荐引擎（4 台）：部署 TensorFlow Serving，提供商品个性化推荐；客户希望通过ASR将VM同步到SouthEast Asia。

DNS + AD（2 台）：Windows Server 作为域控 & DNS，常为 DC01、DC02

NAT + 防火墙（1 台）：Linux-based NAT VM，负责出站流量 & DNAT 映射（如 jumpbox、外部服务）

后端数据库为 Azure Database for PostgreSQL（Flexible Server），已在云端运行，不纳入 VM 迁移范围。

## 实施细节
在 East US 区域创建 Recovery Services Vault，作为 ASR 数据接收与恢复管理的控制中心；启用跨区域存储备份与复制策略，创建保护组和复制策略，设置：
RPO 阈值为 30 分钟；
启用 App-consistent snapshots，每 1 小时生成一次；
保留时间为 5 天（根据客户希望恢复至过去五天内任意时间点的要求）；绑定目标 region 为 East US。
协助客户根据本地 VMware 网络拓扑，在 East US 创建对应的 VNet、子网、NSG；保证子网划分与服务间的网络通信逻辑一致，为未来故障转移后提供无缝连接。

<img width="1012" height="380" alt="image" src="https://github.com/user-attachments/assets/9e0c3a39-a166-4cee-a7a2-7d81c4d05b95" />

<img width="958" height="312" alt="image" src="https://github.com/user-attachments/assets/6aaf7754-5460-4a2d-857f-9e17699b250f" />


创建一个具有必要权限的本地 VMware 帐号（可访问 vCenter、ESXi host），用于检测与操作 VM（关机、迁移、创建磁盘快照等）；配置本地 VMware 资源组与 datacenter 授权连接；在所有需要保护的本地 VM 上安装并注册 ASR Mobility Agent；

在 Recovery Vault 中注册本地 VMware 环境，部署 ASR Configuration Server；配置本地与 Azure East US 的 ExpressRoute（Active/Passive 模式）；验证目标服务在 DR 区域中可与 Azure 数据库、CDN 服务及其他 Azure 资源正常通信；部署 DNS 自动切换策略用于未来快速恢复。

帮助配置本地ExpressRoute与两个Azure区域的连接(Active/Passive模式)，确保主区域故障后，目标区域的服务可无缝与本地系统通信。

## 问题
由于客户设备上安装有 Symantec Antivirus 软件，需将 Mobility Agent 的路径添加至 exclusion list，避免拦截造成安装/运行失败。
到云端机器和AD通信有问题，脱域。
vCenter账号权限不足。
VSS writer的问题。
replicate时发生的网络问题。




