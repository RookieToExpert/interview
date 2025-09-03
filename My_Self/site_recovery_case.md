## 口述版本：
简易版：
在一个客户项目中，他们的生产环境有 13 台 VM 跑在本地 vSphere，上面承载前端、交易 API、推荐引擎、域控和防火墙等关键服务。之前故障暴露出两个痛点：单点风险（比如 NAT 防火墙宕机导致出站流量中断），以及 恢复慢（关键业务 VM 无二级保护）。
针对这些问题，我设计并实施了 Azure Site Recovery 容灾方案。在 East US 部署 Recovery Vault，定义保护组和复制策略，把 RPO 控制在 30 分钟以内，并启用 App-consistent 快照。网络上，通过 ExpressRoute Active/Passive 和 DNS 自动切换，确保一旦主站点故障，东美区域可以快速接管。
同时，在安全治理上采用最小权限的 VMware 服务账号，并同步域控和 DNS，避免切换时出现认证断点。最终经过演练，客户的 RTO 控制在 1 小时内，容灾能力和业务连续性显著提升。

详细版本：
在之前支持的一家客户里，他们的生产环境主要运行在本地 VMware vSphere 上，总共有 13 台虚拟机，覆盖前端、核心交易、推荐引擎、域控 DNS、防火墙等关键模块。后端数据库已经在云端的 Azure Database for PostgreSQL，所以我们主要关注的是这些应用和中间件的 VM 的容灾能力。
在评估阶段，我先梳理了他们的历史故障情况。之前遇到过两类风险：一是本地机房的单点风险，比如 NAT 防火墙 VM 宕机后导致出站流量中断；二是计算和存储层没有二级保护，像 API 服务和推荐引擎这类业务，一旦本地硬件故障，恢复速度很慢，业务 SLA 难以保障。基于这些风险，我们设计了基于 Azure Site Recovery（ASR） 的跨区域容灾方案。
具体实施上，我们在 Azure East US 部署了 Recovery Services Vault 作为统一的复制与恢复控制中心，定义了保护组和复制策略，把 RPO 控制在 30 分钟以内，同时启用 App-consistent 快照，每小时生成一次，以保证业务一致性，支持 5 天内的任意时间点恢复。为了保证未来切换时的业务可达，我们在云端提前搭建了和本地一致的 VNet、子网、NSG，确保网络拓扑对等，这样故障切换后，前后端服务、推荐引擎都能无缝访问数据库和外部服务。
在架构升级上，我们帮助客户优化了网络连通性，采用 ExpressRoute Active/Passive 模式，一旦主站点不可用，东美区域可以快速接管，同时结合 DNS 自动切换策略，缩短业务恢复时间。这里的难点在于 DNS 和 AD 的一致性，我们在目标区域预先同步了域控节点，避免切换时出现认证和解析的断点。
在安全与治理方面，我们创建了专用的 VMware 服务账号，保证最小化权限，同时启用了日志审计，确保迁移和容灾演练过程可追溯。对于 PostgreSQL，虽然不在迁移范围，但我们也验证了目标区域的应用能稳定访问数据库，避免因为跨区延迟导致交易异常。
最后，在交付前我们进行了多轮容灾演练，包括手动触发和自动化切换，验证了系统在故障场景下能够在 30 分钟 RPO、1 小时 RTO 以内完成恢复。通过这次升级，客户整体的业务连续性显著提升，从原本依赖单点机房，提升到具备跨区域灾备能力。

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




