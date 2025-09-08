**口试版**：
在之前一个制造业客户的上云项目里，我主要负责他们核心业务系统的迁移和平台架构的落地。整体思路是把业务层和平台层分开来做设计。比如说 MES，我们把前端应用直接 rehost 到 Azure VM，对应到百度其实就是 BCC 云服务器，现场的数据采集依然留在本地工厂，数据库通过 Azure 的 DMS 去迁移到 Azure SQL，这个在百度可以理解成 DTS 加上 RDS。ERP 系统的 SAP 应用服务器同样是上 VM，数据库也通过 DMS 迁到托管 SQL。至于 SCADA，实时控制部分继续放在工厂端保证低延迟，而数据采集和分析部分 replace 到云上，这块在百度可以类比大数据分析或者 Flink 体系。

平台层我们采用 Hub-Spoke 架构，在 Azure 里就是 CAF 参考架构，在百度就是 VPC + 子网隔离的组合。全球入口通过 Azure Front Door，相当于百度的 CDN 加 WAF，再在区域内接 Application Gateway，对应百度的应用防火墙或智能流量网关。Hub 层集中放置 ExpressRoute Gateway，对应百度的专线或者 VPN 网关，结合 Azure Firewall Premium，就是百度的 CFW，来做统一出站审计和 SNAT。同时我们也部署了 Azure Bastion，相当于百度的堡垒机，提供安全的跳板访问。在解析层，用的是 Azure Private DNS Resolver 加 Private DNS Zone，加上 Private Endpoint，让 SQL、存储、IoT Hub 这类 PaaS 服务都走私网访问，这在百度其实就是 PrivateLink 和 PrivateZone 的结合。

在迁移的流程上，我们分四步。第一是评估，利用 Azure Migrate，对应百度的迁移评估工具 CMC，收集本地 VM 的 CPU、IO 基线，做兼容性检查，最终产出迁移顺序。第二是复制，在本地部署 ASR 或迁移 appliance，相当于百度的 CMC 迁移服务，先全量再增量，利用 hypervisor 的快照机制，VMware 是 CBT，Hyper-V 是 HRL 日志，百度这边也有类似支持，确保一致性。复制过程中我们用了磁盘块校验和 checksum 双重机制，保证增量同步不丢数据。第三是测试，搭建影子环境，也就是 Pilot Light，不切流量的情况下先验证 API 连通性和数据一致性。最后是割接，采用蓝绿或者金丝雀的方式，先把前端应用的流量逐步放到云端，数据库最后一次增量复制通过专线完成，当时的数据量在 50 到 100GB 之间，500Mbps 的专线，大概 25 分钟停机窗口就完成了。

过程中我们也遇到不少挑战。比如 Oracle 到 PG 的兼容性问题，老版本 Oracle 数据类型在 PG 没有直接对应，我们是通过 DMS 配合 Schema Conversion Tool 去做，自动迁了 70%，剩下 30% 手工改造，同时替换 JDBC 驱动。SAP HANA 又不能用 DMS，只能用 HANA System Replication，在 Azure 上跑在 M 系列认证 VM，在百度就是 HANA on BCC 的认证机型。网络上也踩坑过，比如 Private Endpoint 的 DNS 解析，客户当时做了 forwarder 到 168.63.129.16，结果一直 nslookup 失败，我们当时窗口紧，就直接改 host file 先跑通，后面再用 PrivateZone 条件转发解决。还有应用硬编码 IP 的问题，我们一部分通过 FQDN + Private DNS 替代，一部分通过 NAT 和反向代理去兼容，避免服务失联。再比如磁盘 churn 高的问题，我们切到 Premium Blob，在百度对应 BOS 高性能存储，同时把复制压力分散到多个存储账号。带宽瓶颈方面，因为客户有 300 多台 VM 超出单个 appliance 的能力，我们做了 scale-out，也限流策略白天限速、晚上放开带宽。

最终的结果是客户的工厂侧实时控制保持在本地不受影响，核心 ERP 和 MES 成功迁到云上，数据库具备了高可用和自动容灾能力，网络和安全策略集中化，合规性更好，而且整个迁移过程风险可控，有影子环境验证，也有回滚方案。可以说客户既保留了本地的低延迟生产，又获得了云端的弹性和合规保障。如果放在百度智能云，其实也完全能用 BCC、DTS、CFW、PrivateLink、SOC 这一整套体系来落地。

> 可以的，我们的团队是负责对微软云迁移和融灾、备份方向的技术支持。所以有非常多相关的迁移案例，和当前阿里云的架构师岗位有非常多强相关的地方。那可能我印象比较深刻的一个案例，就是在我们当时刚刚对接微软云的Premium客户的时期的一个澳洲的制造企业。那么当时我们接到这个案例的时候，还是一个初期的阶段，架构师团队还在跟客户确认其当前架构，业务和上云目标的一个阶段。然后当时客户环境是双栈虚拟化包含VMware和Hyper-V的虚拟机将近300多台VM。我们是从一个技术支持的目标出发和客户微软架构师团队和客户的虚拟化、网络、运维团队去进行一个对接，提供关于微软云迁移产品的技术咨询和解决方案的服务。初期，我们会和架构师团队去统一迁移的部分口径，包括客户当前整体架构，测试/正式迁移的周期，是否需要稳定回退方案，还包括一些数据安全合规，以及迁后优化等事项，也包含具体的RTO和RPO的指标等。



---
## 完整版
**确认方案：**
讲一下已经确认的架构(把业务层和平台层分开)
我们主要负责客户的核心系统如下：
- **MES**(制造执行系统)：
前端应用rehost到Azure VM上，现场数据采集留在本地厂房。
数据库通过DMS迁移到Azure SQL instance上。
- **ERP**(企业资源计划)：
SAP应用服务器通过rehost至Azure VM。
数据库通过DMS迁移到Azure SQL instance上。
- **应用以及SCADA**(工业制造系统)：
实时控制保留在本地工厂，确保延迟最低，但数据采集以及分析通过replace在Azure上运行。

客户其他管理类系统(监控，配置与运维平台，工单系统，DevOps工具链)，安全类(身份与访问管理 (IAM)，密钥/证书管理，网络与应用安全，审计与合规)，支持类(办公/协作系统，人力/财务/行政系统，客户关系管理 (CRM))等系统由其他团队负责。

---

**实际落地：**
**landing**：
> 简单描述云上landing有哪些部分
- 我们主要负责支持客户landing云上网络底座，采用 Terraform 基础设施即代码统一部署与管控。
- 整体遵循 **Microsoft CAF 的 Hub-Spoke** 参考架构，全局入站通过部署Azure Front Door(全球加速 + L7 WAF + 多区域故障切换)，后端接各区域 Application Gateway（WAF），在区域内实现TLS 终结与路径路由。
- 使用Hub+Spoke方式，Hub:
    - 放 VPN/ExpressRoute Gateway，BGP启用动态路由Hub Gateway（BGP）与本地互通，按域/前缀精确控制传播与访问面，并禁用无关 Spoke 的路由传播。
    - 部署 Azure Bastion 作为安全跳板访问。
    - 以及部署Azure Firewall，所有出站统一经 Azure Firewall Premium 审计与策略控制（含威胁情报/URL FQDN 细粒度放通），由 Firewall 做 SNAT。其它 测试Spoke可以走 NAT Gateway 本地直出以出站，SNAT伸缩与成本效率。
    - 部署 Azure Private DNS Resolver（Hub）+ Private DNS Zones，实现 DNS Split-horizon：工厂内部域名定向转发，本地/公共域名按规则集转发；PaaS（如 Azure SQL、存储、IoT Hub）统一 Private Endpoint 私有化访问与解析。
    - 北向入站：Internet → AFD(WAF) → AppGW(WAF) → 应用子网（私有回源优先，搭配 Private Link/PE）。
    - (南向出站)生产环境出站：生产 Spoke 的应用子网绑定绑定两条路由，一条到本地网络（例如 10.10.0.0/16，或工厂侧 IP 段） → 下一跳 ExpressRoute Gateway。在 UDR：0.0.0.0/0 → Azure Firewall（Hub）。
    - (东西向)跨 Spoke：通过 UDR 将对端网段下一跳指向 Firewall，在 Firewall 显式放通；同一 Spoke 内由 NSG 进行最小化放行与隔离。
    - Azure Monitor/Log Analytics + Defender for Cloud；按需汇入 Microsoft Sentinel 实现 SOC 分析与告警编排。
    - 预留 应急直连通道（Emergency VPN/Direct Access）受控启用，用于突发场景下的受限访问与故障排障。
    - Azure SQL（Auto-failover Groups + Private Endpoint），以区域内高可用 + 跨区主动/被动为主；结合业务制定 分层同步/子集同步 策略而非盲目全量跨区复制，兼顾一致性、带宽与成本。


    ![alt text](3560f76862667324ff7d47f11a40b69.png)



**评估：**
那么迁移前，我们会协助客户使用微软Migrate中的assertment评估工具去对它当前架构做基线评估，我们会通过在客户本地部署的Azure迁移服务器，去收集虚机的数据包括但不限于CPU利用率、磁盘的IO读写等等。按照P95性能样本再加上客户确认的安全系数，得出一个推荐Azure虚机的SKU。除此之外，评估还会包括就绪性整改清单，主要是去检查本地服务器和云服务器的兼容性，包括像OS版本，磁盘大小，内核版本等，此清单会评估客户本地虚机的一些改造列表。最后也会产出他本地的依赖图，最终我们得出迁移顺序是先迁移Web/静态/跳板机，然后迁移中间件与业务API，最后迁移核心数据库。那么可能我们整体的目标方案采用一个专线Express route加上云上的private endpoint的数据接收终端，所以相当于数据面采用私网复制，控制面最小放通关于一些公有终端的443端口。

**复制阶段**：
再到搭建复制链路，这一步我们会协助客户在本地部署ASR/迁移Appliance，初始做全量备份，是因为虚拟机的硬盘和内存本质上都是由宿主机模拟出来的文件和资源， Hypervisor 在宿主层完全控制 Guest 的虚拟磁盘和内存，宿主机只要把这些文件和内存当下的状态“冻结”，直接在存储虚拟化层重定向写入生成差分文件，并在需要时捕获 vRAM 状态，而无需进入 Guest OS，得到一个快照文件：
- VMware 快照文件：差分 .vmdk + 元数据 .vmsd +（可选）内存状态 .vmsn

- Hyper-V 快照文件：差分 .avhdx + VM 配置元数据 +（可选）内存 .bin / 设备状态 .vsv


VMware和Hyper-V是通过基于VMware的CBT，Hyper-V侧用HRL日志跟踪去然后做增量备份去做到数据一致性。关于复制周期，我们采用的是基于上次增量备份耗时的一半，最短不低于1小时，以及最长不超过12小时，保证后续数据同步并维持应用一致性。
关于数据校验机制：
- 磁盘chunk校验：在增量备份阶段，我们会通过将源磁盘划分成512字节的扇区，每个扇区都映射到bitmap中的一个bit，同时，在数据传输到azure的托管磁盘后，托管磁盘也会创建一个bitmap，最后会通过对比两个bitmap，确保没有遗漏任何已更改的块，如果发现有任何不匹配的情况，当前复制周期会被视作为失败，那么在下一次复制周期，又会重新进行同步，断点复制同步的机制。

- checksum校验：第二个是会确保当前azure的托管磁盘与源磁盘的数据是否相同，简单来说就是每次已上传的数据都会被作为blob进行压缩和加密后存储到存储账户中，并在压缩前计算此块的校验和(checksum)，如果不匹配，则不会写入azure磁盘中，并且视为当前周期失败，和刚刚一样，在下一次复制周期，又会重新进行同步。

**测试阶段(Pilot Light / Shadow Migration)**:
在正式迁移阶段，我们会分批次进行测试迁移，期间先不切流量，在云端验证各应用之间API能跑通，运行一个影子环境，检查一些基础虚拟机功能，也包括对数据库进行业务数据校验测试，行业里叫 Pilot Light / Shadow Migration，是个过渡阶段。



**正式割接**：
把实际业务流量切换到云端，停用或逐步下线本地 IDC：
    - 数据：完成 最终增量复制 + 数据校验。

    - 应用：通过 蓝绿/金丝雀发布 切换流量。

    - 网络：调整 DNS / 负载均衡指向云端。

    - 运维：监控迁移后性能指标，确保 SLA 达标。
测试迁移完成之后，会进入正式迁移割接阶段。通过使用入口frontdoor，逐渐放流至云端web应用，数据库任然指向本地数据库，此时保持专线打通，验证云端前端应用运行正常，逐步放流至100%时，暂时保留本地前端应用，作为回滚备份方案。此时对于数据库，暂时停止本地数据库写入操作，进行最终增量复制，割接的总量数据约为50-100GB左右，专线带宽为500Mbps，总停机窗口耗时为25分钟左右，停机期间，通过DNS切换指向云端数据库，确保割接完成后，应用能立马上线，并反向同步云端数据库至本地数据库，实现将本地数据库作为暂时的容灾区域，并作为回滚方案。(确认 生产 Spoke → Firewall → 云端 SQL Private Endpoint 的出站端口（1433/TCP 或相应）已放通，否则割接时 DMS/应用访问可能失败。)

## 遇到的问题：
#### 数据库迁移：
1. Oracle转到azure db for PGsql：
    1. 版本不兼容， 老版本 Oracle (Oracle 11gR2 (11.2.0.4))的数据类型、函数在 PG 中没有对应实现。
    2. SDK接口不一致，应用层调用 JDBC/ODBC 时要替换 driver。
    3. 数据格式不同，Oracle 的 NUMBER、DATE、CLOB 在 PG 中需要映射，部分触发器（如 BEFORE INSERT 级别）迁移后逻辑冲突。

- 解决方案：
    - 使用 Azure DMS + Schema Conversion Tool (SCT) 进行自动化迁移评估和转换，识别 70% 自动可转化，30% 需人工改造。
    - 制定 数据类型映射表统一替换规则（NUMBER → NUMERIC，CLOB → TEXT）。
    - 应用 JDBC 驱动替换为 org.postgresql.Driver，.NET 项目替换 Npgsql。
    - 通过 读写分离 + 索引优化 弥补 PG 在性能上的不足。
    - 建立 双写/回切机制（例如 Oracle 作为主库，PG 做增量同步，验证后再切换）。
    - 建立 双活同步：Oracle 作为主库，PG 增量同步（通过 GoldenGate → Kafka → PG），验证后再平滑切换。

2. SAP HANA官方工具不支持：
    1. Azure DMS 不支持 SAP HANA，HANA 对硬件依赖高（需要认证的 VM SKU / 专用裸机），迁移停机窗口难以接受（ERP 系统必须 7x24）。
    2. HANA license 绑定硬件，需要与 SAP 协调。
    3. 数据量极大（TB~几十 TB），全量导入导出不可行。

- 解决方案：
    1. 使用 SAP HANA System Replication (HSR)，先做全量复制，再保持增量实时同步，最终切换时只需停机几分钟。
    2. 对于版本升级场景，使用 SAP SUM with DMO（边迁移边升级）。
    3. 在 Azure 上部署时选择 认证 VM（M 系列、Mv2）或 HANA Large Instance，确保性能。
    4. 提前和 SAP 确认 license 转移方式。
    5. 使用 ANF (Azure NetApp Files) 或高速专线传输（ExpressRoute）来减少数据迁移时间。

3. 安全与合规：
    1. 云端启用数据库自带TDE加密，对静态数据进一步加密。
    2. 要求所有应用通过 SSL/TLS 连接数据库，拒绝明文连接。
    3. 将相关TDE加密密钥，传输层加密文件，应用访问凭证包括用户名密码等统一管理交由 Azure Key Vault，满足密钥轮换、审计要求。
    4. 在云端数据库(内置 审计日志导出)上启用 审计日志 (Audit Logs)，记录所有用户的登录、查询、DDL、DML 操作。将日志集中导出到 Azure Monitor / Log Analytics 满足企业合规（SOX、ISO、PCI DSS 等）。
    5. 利用 Azure Policy + Defender for SQL 自动生成合规性检查报告（例如是否启用了加密、是否存在高危配置）。定期导出合规状态，作为内审和外部监管的审计凭据。

- 解决方案：启用 TDE（透明数据加密）+ Azure Key Vault 做密钥管理。
#### 网络：
1. 迁移网络遇到的问题：
当时一开始卡在私网复制出了问题，一开始是azure终端的private endpoint不联通，客户一直出问题的原因是他们在dns中加了一个forwarder到azure的public dns ip 168.63.129.16，然后一直还是nslookup出问题，当时我们因为迁移窗口短，所以是直接到host file上加映射IP和地址解决的，
2. 迁移后，IP发生改变，先前使用IP互相调用的应用会失联，怎么办？
    #### 情况一：用户本地可以将IP硬编码统一改成域名：
    1. 用FQDN取代硬编码，**本地DNS**服务器做域名解析**指向本地IP**。
    2. 在云端做好Azure private DNS Zone，并打通云端DNS resolver和本地的网络，在本地DNS做conditional forwarded。
    3. 降低TTL到60-300秒，预热缓存。
    4. 迁移日，把域名的权威解析/记录切换成云端IP/Private endpoint；客户端随TTL过期后自动指向新后端。
    #### 情况二：本地全面改代码代价太大：
    ##### A. NAT转换
    1. 本地放置一台NAT/防火墙设备(F5、Palo等等)，把目的地为旧IP流量引流到NAT，然后通过NAT做DNAT规则，比如旧IP:端口号指向新IP:端口号。
    2. 为避免回程不对称，对所有DNAT规则启用SNAT，把源改成NAT侧地址。
    3. 云端确保有Expressroute/VPN，VNet到本地的路由包含本地网段，允许回程到NAT的地址。
    ##### B. 反向代理/网关：
    1. 本地部署一台网关/代理(Nginx/F5)，对外仍监听旧IP/端口，转发到云端后端。
    2. 在代理上监听旧IP：端口并且后端指向新IP：端口。
    3. 云端部署ILB，将迁移上来的应用放入后端。

#### 割接问题：
1. 简单一点，看客户需要做蓝绿，还是灰度。
2. 蓝绿则就是比较简单，比如拿azure举例子，在云端准备好一个公网入口的形态，可以是Azure Front door(全球加速 + 权重/健康探测 + WAF，推荐),Azure application gateway(区域入口，四层配合公有 SLB)或者就是简单的公有load balancer(最轻，但没有 L7 能力；灰度靠上层或 Traffic Manager)。
3. 拿AFD举例子，在AFD准备两个入口，一个是你本地的公网出口(可能是一个反代理服务器)的公网地址，一个是你的云上公网地址，割切时，将权威DNS的对外域名改成CNAME指向AFD的endpoint，之后你就可以在AFD上切换优先级，把优先级改成云上公网地址。但在这之前你还要在AFD上做一些校验和配置等等，AFD需要确保这个域名是你的。
#### disk churn：
然后当时解决了PE解析的问题以后，最多的问题还是disk churn/iops超了限制，那么我们就是要去切换成high churn模式，把缓存数据的cache storage account改成premium block blob，这样单机可提升到100MB/s，当然还是有部分VM尤其是数据库本地磁盘churn太高了，我们当时就把复制压力分散到多个存储账户，避免单个账户的入口限速，当然还有一些磁盘就是高写入，那我们只能先去排除掉这些高churn磁盘，然后再做迁移，事后再去把剩余几个高churn的磁盘去单独做数据传输，除了单个disk churn的问题，还有就是客户客户复制超过300台VM，超出了单个appliance支持的上限，需要scale out appliance。
#### 宽带压力：
就是并行复制大量磁盘时，本地带宽压力比较大，所以也是分批去进行复制，并且也是改了VMware appliance上的限流策略，白天的时候限流100Mb/s，晚上放开,Hyper-V是通过C:\Program Files\Microsoft Azure Recovery Services Agent\bin\wabadmin.msc去调整限速策略。

监控与回退：

当然，过程中肯定不会像我上面说的那么流畅，我们肯定是遇到了非常多大大小小的问题，因为时间关系，我就挑其中我印象比较深刻的一到两个问题来回答。第一个就是客户他们有部分比较老的应用，底层代码是通过硬编码基于IP通信和互相调用，但是之后客户本地和云端是要通过专线打通，那么云端IP和本地IP网段肯定是不能overlap重合的，此时面临的问题就是虚机上云后这个IP发生变化了，那代码中还在去尝试调用旧IP，肯定就会出现调用失败的情况。那我们当下，基于之前迁移案例经验，给到他们开发团队的建议是使用FQDN，域名的方式去替代硬编码。那客户这边是不同意的，他们不希望在迁移前后去对本地做大规模的改造，尤其是在生产环境中。所以我们当下给到另一个方案，就是通过本地防火墙中设置一个DNAT和SNAT规则，将旧IP指向云端新IP，并通过修改路由表将虚机下一跳到防火墙，这一步也需要确保本地防火墙可以和云端内部负载均衡器之前通过专线能互相访问。确保客户完成迁移之后，应用还是能通过旧IP去进行交流。那么这个其实只是也只是一个现阶段为了保证迁移后应用能正常运行的临时方案，未来客户上云，还是建议他们去把他的底层代码使用FQDN替换IP。

落地过程中有三类典型挑战。我方快速闭环：其一是私网解析，一开始客户把Forwarder指向168.63.129.16导致PE不通，窗口期先以Hosts应急，随后用Private DNS Zone+条件转发长期修复；其二是IP变更导致耦合，优先以FQDN替代硬编码、降低TTL并把权威解析CNAME到Front Door，若改造成本高则在本地做DNAT/SNAT或反向代理保证回程对称；其三是高写入与带宽瓶颈，开启High-churn模式把缓存切到Premium Block Blob、分散到多存储账户并横向扩容Appliance，对极高写入的磁盘单列后置处理，同时实施分批复制与日夜限流策略。
结果方面，首波无状态工作负载大量改为PaaS，上云服务器量减半；通过右尺码、弹性与分层存储实现明显TCO优化；专线+PE+最小权限与全链路审计满足合规；分波+演练+可回退的发布策略保证窗口可控、零回滚事故。复盘看，这次是把TOGAF的“业务对齐—基线评估—目标架构—机会与方案—迁移计划—实施治理”完整工程化：先治理后迁移（账号/网络/DNS/权限基线），先演练后切换，能PaaS不硬搬迁，以数据面为王控制面最小暴露，最终实现“迁得上去、跑得稳、管得住、花得省”。
客户是一个微软unified的大客户，好像是一个澳洲比较大的制造业的企业，然后本地有分别两套vSphere/Hyper-V集群托管有超过300+VM，应用以Web层，一些静态资源，nginx啊等等，然后还有一层应用层，包括他们有大量服务器部署python等api的微服务还有一些api网管，redis和一些日志服务器等，还有数据层包括他们用的oracle数据库，postgreql等等。和少量中间件为主，然后他们希望变更窗口越短越好，那我们是和他们的微软架构师团队和他们的技术团队主要包括VM集群的管理运维团队和他们的网络团队等对接。

#### Azure Site Recovery 复制设备:
1. 设备中的所有组件都与复制设备协调。此服务负责监督所有端到端 Site Recovery 活动，包括监视受保护计算机的运行状况、数据复制、自动更新等。
2. 虚拟机会使用VMware的CBT技术去进行快照管理，然后通过端口 HTTPS 443和HTTPS 9443端口与这个复制设备appliance。进行通信，向设备发送复制数据（入站）。
3. 该设备接收复制数据，对其进行优化和加密，然后通过端口 443 将其发送到 Azure 存储。复制数据日志首先存储在 Azure 中的缓存存储帐户中。
4. 这些日志经过处理后，数据存储在 Azure 托管磁盘（称为asrseeddisk）中。恢复点将在此磁盘上创建。

#### 迁移前评估
1. performance-based，按照当前的CPU/内存利用率，还有磁盘IOPS/吞吐去计算，得出一个推荐的azure sku.
2. 简单来说azure migrate会**通过appliance去收集数据**，**比如vmware是每20s，hyper-V是每30s取样创建一个数据点**，然后每10分钟聚合成一个峰值点，然后发送到Azure migrate。
3. 评估期一般是一周到一个月不等，按照客户设置的**百分位利用率(常用P95,95百分位)取代标点，再乘以安全系数(1.3-2.0不等)**去给出推荐规格。
4. 比如客户当时有一个16vCPU的服务器，然后根据性能数据样本去按照升序排序，然后最终评估出该服务器在第95百分位内仅利用了20%的可用CPU，因此其实只需要4vCPU就足以支持它的负载，然后最后客户确定了一个安全系数为2，我们最终得出的建议是8核vCPU，
5. 当然还会有关于**Azure Readiness的评估**，比如会去判断服务器的Windows版本是不是过低，或者是有服务器磁盘超过64TB也无法支持直接迁移上云等，然后azure migrate会给相应的remediation guidance在迁移前去该升级升级，该修复修复。
6. 当然我们还会根据azure migrate**产出的依赖图**去做一个成组迁移清单，把一些强依赖集群，规划成一组迁移。

#### 底层复制技术讲解
(vmware appliance上会有data replication agent和gateway agent)
然后就是进行数据的第一次传输也叫initial replication，azure migrate第一次会给每个VM都做一次VMware snapshot，然后，通过azure appliance将快照磁盘中的完整数据副本通过HTTPS和TLS 1.2先传到云上的一个storage account，然后再通过storage account复制到目标订阅中的托管磁盘(静态加密)，初始复制完成后，会进入到增量复制的阶段，相当于基于上一次复制以来发生的所有数据更改会被打包复制并写入副本托管磁盘，确保托管磁盘数据和源VM保持同步。底层用的是VMware的CBT技术获得当前快照与上次成功的快照之间的更改，当然最后正式客户点迁移的那一刻，会最后进行一次数据校验，把剩余所有剩余的更改过的数据最后复制到托管磁盘，然后此时必须关闭本地VM，防止迁移过程有任何新增数据无法同步。
同时azure migrate也会有一个数据校验的方式，第一个是确确保每次复制周期同步上来的数据是一致性的，在增量备份阶段，我们会通过将源磁盘划分成512字节的扇区，每个扇区都映射到bitmap中的一个bit，同时，在数据传输到azure的托管磁盘后，托管磁盘也会创建一个bitmap，最后会通过对比两个bitmap，确保没有遗漏任何已更改的块，如果发现有任何不匹配的情况，当前复制周期会被视作为失败，那么在下一次复制周期，又会重新进行同步。第二个是会确保当前azure的托管磁盘与源磁盘的数据是否相同，简单来说就是每次已上传的数据都会被作为blob进行压缩和加密后存储到存储账户中，并在压缩前计算此块的校验和(checksum)，如果不匹配，则不会写入azure磁盘中，并且视为当前周期失败，和刚刚一样，在下一次复制周期，又会重新进行同步。
#### 复制周期逻辑讲解
复制周期的逻辑是先进行初次的完整复制，并在初次完整复制后马上进行第一个增量备份，下一个增量备份会通过一个公式，min[max[1 hour, (<Previous delta replication cycle time>/2)], 12 hours]，这个公式比较抽象，简单来说就是下一次周期会在上一次增量备份所花费的时间除以二，并且这个时间不会低于1小时也不会高于12小时。假如上一次增量备份花了8小时才完成，那下一次增量备份会在4小时以后进行。

#### Hydration
然后最终我们才开始正式的迁移，当然迁移的背后，azure migrate会做一个叫hydration的过程，简单来说就是azure会临时起一台中介VM，把源盘挂上然后对驱动啊，代理什么的做必要的改动，再生成最终的VM。然后就是正式迁移了，正式迁移的过程中，因为是分批迁移，所以要确保先迁移上去的web vm啊，api啊还能和本地数据库连接，以及就是要确保把业务域名更换到客户云上的frontdoor等，当然最后最重要的数据库迁移，就还是会有一个短暂的停机，并且azure migrate再迁移前会做一次last sync，确保数据一致性，然后再正式迁移。

#### Hyper-V底层机制
关于hyper-V,就是基于Hyper-V replica去追踪每次磁盘的变化数据，并记录到log files(hrl文件)，这个log文件与磁盘是在同一个文件夹当中，每个磁盘都会有一个关联的hrl文件，会发送到云端的storage account，为每次增量备份去做一个追踪。

## 遇到的问题：
#### 数据库迁移：
1. Oracle转到azure db for PGsql：
    1. 版本不兼容， 老版本 Oracle (Oracle 11gR2 (11.2.0.4))的数据类型、函数在 PG 中没有对应实现。
    2. SDK接口不一致，应用层调用 JDBC/ODBC 时要替换 driver。
    3. 数据格式不同，Oracle 的 NUMBER、DATE、CLOB 在 PG 中需要映射，部分触发器（如 BEFORE INSERT 级别）迁移后逻辑冲突。

- 解决方案：
    - 使用 Azure DMS + Schema Conversion Tool (SCT) 进行自动化迁移评估和转换，识别 70% 自动可转化，30% 需人工改造。
    - 制定 数据类型映射表统一替换规则（NUMBER → NUMERIC，CLOB → TEXT）。
    - 应用 JDBC 驱动替换为 org.postgresql.Driver，.NET 项目替换 Npgsql。
    - 通过 读写分离 + 索引优化 弥补 PG 在性能上的不足。
    - 建立 双写/回切机制（例如 Oracle 作为主库，PG 做增量同步，验证后再切换）。
    - 建立 双活同步：Oracle 作为主库，PG 增量同步（通过 GoldenGate → Kafka → PG），验证后再平滑切换。

2. SAP HANA官方工具不支持：
    1. Azure DMS 不支持 SAP HANA，HANA 对硬件依赖高（需要认证的 VM SKU / 专用裸机），迁移停机窗口难以接受（ERP 系统必须 7x24）。
    2. HANA license 绑定硬件，需要与 SAP 协调。
    3. 数据量极大（TB~几十 TB），全量导入导出不可行。

- 解决方案：
    1. 使用 SAP HANA System Replication (HSR)，先做全量复制，再保持增量实时同步，最终切换时只需停机几分钟。
    2. 对于版本升级场景，使用 SAP SUM with DMO（边迁移边升级）。
    3. 在 Azure 上部署时选择 认证 VM（M 系列、Mv2）或 HANA Large Instance，确保性能。
    4. 提前和 SAP 确认 license 转移方式。
    5. 使用 ANF (Azure NetApp Files) 或高速专线传输（ExpressRoute）来减少数据迁移时间。

3. 安全与合规：
    1. 云端启用数据库自带TDE加密，对静态数据进一步加密。
    2. 要求所有应用通过 SSL/TLS 连接数据库，拒绝明文连接。
    3. 将相关TDE加密密钥，传输层加密文件，应用访问凭证包括用户名密码等统一管理交由 Azure Key Vault，满足密钥轮换、审计要求。
    4. 在云端数据库(内置 审计日志导出)上启用 审计日志 (Audit Logs)，记录所有用户的登录、查询、DDL、DML 操作。将日志集中导出到 Azure Monitor / Log Analytics 满足企业合规（SOX、ISO、PCI DSS 等）。
    5. 利用 Azure Policy + Defender for SQL 自动生成合规性检查报告（例如是否启用了加密、是否存在高危配置）。定期导出合规状态，作为内审和外部监管的审计凭据。

- 解决方案：启用 TDE（透明数据加密）+ Azure Key Vault 做密钥管理。
#### 网络：
1. 迁移网络遇到的问题：
当时一开始卡在私网复制出了问题，一开始是azure终端的private endpoint不联通，客户一直出问题的原因是他们在dns中加了一个forwarder到azure的public dns ip 168.63.129.16，然后一直还是nslookup出问题，当时我们因为迁移窗口短，所以是直接到host file上加映射IP和地址解决的，
2. 迁移后，IP发生改变，先前使用IP互相调用的应用会失联，怎么办？
    #### 情况一：用户本地可以将IP硬编码统一改成域名：
    1. 用FQDN取代硬编码，**本地DNS**服务器做域名解析**指向本地IP**。
    2. 在云端做好Azure private DNS Zone，并打通云端DNS resolver和本地的网络，在本地DNS做conditional forwarded。
    3. 降低TTL到60-300秒，预热缓存。
    4. 迁移日，把域名的权威解析/记录切换成云端IP/Private endpoint；客户端随TTL过期后自动指向新后端。
    #### 情况二：本地全面改代码代价太大：
    ##### A. NAT转换
    1. 本地放置一台NAT/防火墙设备(F5、Palo等等)，把目的地为旧IP流量引流到NAT，然后通过NAT做DNAT规则，比如旧IP:端口号指向新IP:端口号。
    2. 为避免回程不对称，对所有DNAT规则启用SNAT，把源改成NAT侧地址。
    3. 云端确保有Expressroute/VPN，VNet到本地的路由包含本地网段，允许回程到NAT的地址。
    ##### B. 反向代理/网关：
    1. 本地部署一台网关/代理(Nginx/F5)，对外仍监听旧IP/端口，转发到云端后端。
    2. 在代理上监听旧IP：端口并且后端指向新IP：端口。
    3. 云端部署ILB，将迁移上来的应用放入后端。

#### 割接问题：
1. 简单一点，看客户需要做蓝绿，还是灰度。
2. 蓝绿则就是比较简单，比如拿azure举例子，在云端准备好一个公网入口的形态，可以是Azure Front door(全球加速 + 权重/健康探测 + WAF，推荐),Azure application gateway(区域入口，四层配合公有 SLB)或者就是简单的公有load balancer(最轻，但没有 L7 能力；灰度靠上层或 Traffic Manager)。
3. 拿AFD举例子，在AFD准备两个入口，一个是你本地的公网出口(可能是一个反代理服务器)的公网地址，一个是你的云上公网地址，割切时，将权威DNS的对外域名改成CNAME指向AFD的endpoint，之后你就可以在AFD上切换优先级，把优先级改成云上公网地址。但在这之前你还要在AFD上做一些校验和配置等等，AFD需要确保这个域名是你的。
#### disk churn：
然后当时解决了PE解析的问题以后，最多的问题还是disk churn/iops超了限制，那么我们就是要去切换成high churn模式，把缓存数据的cache storage account改成premium block blob，这样单机可提升到100MB/s，当然还是有部分VM尤其是数据库本地磁盘churn太高了，我们当时就把复制压力分散到多个存储账户，避免单个账户的入口限速，当然还有一些磁盘就是高写入，那我们只能先去排除掉这些高churn磁盘，然后再做迁移，事后再去把剩余几个高churn的磁盘去单独做数据传输，除了单个disk churn的问题，还有就是客户客户复制超过300台VM，超出了单个appliance支持的上限，需要scale out appliance。
#### 宽带压力：
就是并行复制大量磁盘时，本地带宽压力比较大，所以也是分批去进行复制，并且也是改了VMware appliance上的限流策略，白天的时候限流100Mb/s，晚上放开,Hyper-V是通过C:\Program Files\Microsoft Azure Recovery Services Agent\bin\wabadmin.msc去调整限速策略。


