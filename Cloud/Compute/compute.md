## 💻 多云计算服务对比表（Compute）

| 类别                 | Azure                                | AWS                                | 阿里云                             | 说明 / 使用场景                                                                 |
|----------------------|---------------------------------------|------------------------------------|------------------------------------|--------------------------------------------------------------------------------|
| 虚拟机（IaaS）        | Azure VM                             | EC2                                | ECS（云服务器）                     | 基础虚拟机服务，适合自建服务、旧系统迁移、操作系统自定义                                                      |
| 容器服务（轻量级）     | [Container App](https://github.com/RookieToExpert/interview/tree/main/Cloud/Compute/Azure_Compute/Container_app)                       | App Runner / ECS + Fargate         | 容器服务 ASK（Serverless K8s）      | 托管容器服务，免维护集群，支持自动伸缩，适合 API、微服务、低运维场景                                          |
| 容器实例              | [Container Instance (ACI)](https://github.com/RookieToExpert/interview/blob/main/Cloud/Compute/Azure_Compute/Azure_container_instances.md)             | ECS RunTask / Fargate              | 弹性容器实例（ECI）                 | 最快上线方式，适合一次性脚本、测试、定时任务等轻量临时工作负载                                                  |
| Web 应用部署平台       | [Web App for App Service](https://github.com/RookieToExpert/interview/blob/main/Cloud/Compute/Azure_Compute/Azure_App_Service.md)              | Elastic Beanstalk / Amplify        | Web应用托管 / 函数计算              | 支持代码部署，自动 HTTPS、CI/CD，适合中小企业常规 Web 应用开发                                                   |
| 托管 Kubernetes       | AKS (Azure Kubernetes Service)       | EKS                                | ACK（容器服务 Kubernetes 版）       | 托管 K8s，适合微服务架构、企业集群、多服务部署                                                                    |
| 批处理 / 高并发任务    | [Azure Batch](https://github.com/RookieToExpert/interview/blob/main/Cloud/Compute/Azure_Compute/Azure_Batch.md)                          | AWS Batch                          | Batch Compute / 计算任务调度平台     | 适合大规模仿真、渲染、模型训练、高并发无状态任务                                                                  |
| Serverless 函数服务   | [Azure Functions](https://github.com/RookieToExpert/interview/blob/main/Cloud/Compute/Azure_Compute/Azure_Function.md)                      | AWS Lambda                         | 函数计算（Function Compute）        | 无服务器函数计算，适合事件驱动、Webhook、自动任务、轻量异步处理                                                   |
| 大数据 / MapReduce   | HDInsight / Synapse Analytics       | EMR / Glue                         | E-MapReduce / MaxCompute           | Hadoop / Spark 集群，适合大数据处理、ETL、离线分析任务                                                            |

## 自动伸缩模式

## 🤖 多云 Compute 自动伸缩模式对比表（Azure / AWS / 阿里云）

| 服务类型          | Azure 自动伸缩模式                                                                                                                                 | AWS 自动伸缩模式                                                                                                                                      | 阿里云自动伸缩模式                                                                                                                                     |
|-------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|
| 虚拟机            | 使用 **VM Scale Set (VMSS)**，支持根据 CPU、内存、队列长度等指标扩缩；可接 Azure Monitor 自定义指标                                              | 使用 **EC2 Auto Scaling Group (ASG)**，支持多指标触发、计划伸缩、预测性扩缩容（Forecast-based Scaling）                                           | 使用 **ESS（弹性伸缩服务）**，支持按监控指标、自定义脚本、定时计划等触发，管理略繁琐                                                               |
| 容器服务          | **Container App** 支持根据 HTTP 请求数、并发量、CPU/内存用量自动扩缩；支持 KEDA（事件驱动自动伸缩）；**支持 scale to 0**                          | **App Runner** 内建自动扩缩容，按并发请求数或 CPU 自动扩缩；**支持 scale to 0**；Fargate + ECS 可用 Application Auto Scaling 管理                | **ASK（Serverless K8s）** 原生支持 Pod 自动伸缩（HPA），Node 自动弹性调度；支持按 QPS、资源、事件等；**支持 scale to 0**                              |
| 容器实例（无编排）| **Container Instance (ACI)** 不支持自动伸缩，每个任务必须手动创建或通过外部逻辑（如 Logic App / Function）触发                                     | **Fargate Task** 本身无自动伸缩能力，但 ECS Service 可与 Auto Scaling 结合使用进行横向伸缩                                                         | **ECI（弹性容器实例）** 无原生自动扩缩功能；需借助 ACK + 弹性伸缩控制器组合实现                                                                      |
| Web 应用平台      | **App Service Plan** 可配置自动缩放规则：按 CPU/内存/请求数等指标扩缩；需选 Standard / Premium Plan 才支持                                          | **Elastic Beanstalk** 支持 EC2 自动扩缩容，通过 Load Balancer + ASG 管理后端实例                                                                   | Web 托管平台支持基于 ECS 自动扩缩（ESS），需手动配置；规则有限，缺少深度集成                                                                         |
| Kubernetes 托管   | **AKS** 支持 Node Pool 自动扩缩（Cluster Autoscaler）、Pod HPA、KEDA；适配容器化任务和事件驱动服务                                                  | **EKS** 同样支持 Pod HPA、Cluster Autoscaler；支持 AWS Application Auto Scaling 扩展控制                                                            | **ACK** 支持 Pod 自动扩缩（HPA）、节点自动扩缩（CA）、部分服务可配置伸缩策略脚本                                                                      |
| 批处理计算        | **Azure Batch** 支持自动按任务数量和负载动态调整 Pool 节点数；结合低优先级 VM 可极限压缩成本                                                       | **AWS Batch** 使用 Compute Environment 自动调度 Spot/On-Demand 实例，任务到达后动态扩容                                                           | **阿里云 Batch Compute** 支持任务级调度、弹性集群组合；弹性性强，但伸缩控制需显式定义                                                                |
| Serverless 函数   | **Azure Functions** 天生支持自动伸缩，按事件触发和并发数动态扩容；**支持 scale to 0**；支持 KEDA + queue + custom metrics                        | **AWS Lambda** 是 Serverless 的代表，按并发 + 请求自动扩缩，默认数千并发起步，**scale to 0 自动触发**                                             | **函数计算（FC）** 全面支持并发、资源使用、时间等自动扩缩；国内体验最佳；支持 Provisioned Concurrency 保底并发配置                                     |

我把三大云的计算资源按 IaaS、CaaS、PaaS、FaaS 分类梳理过一遍，也分别测试了弹性能力和启动速度。选择时，我通常会从任务持续时间、状态性、并发量和团队运维能力来判断用哪种 compute 资源。比如要运行训练任务我就优先考虑 Azure Batch / AWS Batch；而高并发无状态服务我会选 Container App / App Runner。

## ⚡ 三大云平台 Compute 启动速度对比

| 服务类型          | Azure 启动速度       | AWS 启动速度         | 阿里云启动速度         | 说明 |
|-------------------|----------------------|-----------------------|-------------------------|------|
| 虚拟机（VM / ECS） | 🐌 1~5 分钟           | 🐌 1~3 分钟             | 🐌 1~3 分钟               | 启动包括 OS 引导 + 初始化，适合长期运行服务 |
| 容器服务（托管）   | ⚡ 3~10 秒            | ⚡ 2~10 秒              | ⚡ 2~15 秒                | 无状态服务部署快，支持并发，请求响应时间低 |
| 容器实例（无编排）| 🐇 5~15 秒            | 🐇 5~30 秒              | 🐇 3~10 秒                | 启动迅速但无自动扩缩容，适合一次性任务 |
| Web 应用平台       | 🐢 15~60 秒           | 🐢 30~90 秒             | 🐢 20~60 秒               | 冷启动时间长，适合持续运行型 Web 应用 |
| Kubernetes Pod     | ⚡ 20~60 秒（Pod）    | ⚡ 20~90 秒（Pod）       | ⚡ 30~90 秒（Pod）         | 节点冷启动慢，Pod 启动受镜像大小影响 |
| Batch 计算任务     | 🦥 30 秒 ~ 数分钟     | 🦥 30 秒 ~ 数分钟        | 🦥 30 秒 ~ 数分钟          | 启动慢但预期合理，主要用于大规模任务调度 |
| Serverless 函数    | ⚡ 0.5~3 秒           | ⚡ 0.1~1 秒              | ⚡ 0.1~1 秒                | 冷启动快，极致弹性，适合事件驱动和高并发 |

不同服务的启动速度直接影响请求响应延迟，Serverless 虽然启动最快，但可能受冷启动影响；而容器服务如 Azure Container App 可通过保温实例缓解这个问题。对于高并发突发型业务我建议用容器服务 + 自动伸缩，而不是传统虚机，后者启动速度太慢，抗不住压测。

## 🧠 三大云平台 Compute 服务状态相关性对比

| 服务类型          | Azure 状态相关性     | AWS 状态相关性         | 阿里云状态相关性       | 是否推荐用于无状态服务 | 说明 |
|-------------------|----------------------|-------------------------|-------------------------|------------------------|------|
| 虚拟机（VM / ECS） | ✅ 可持久化（有状态）  | ✅ 可持久化（有状态）    | ✅ 可持久化（有状态）    | ❌ 不推荐（除非你管得住） | OS 层/磁盘/内存均持久，适合自建数据库等有状态服务 |
| 容器服务（托管）   | ✅ 推荐无状态         | ✅ 推荐无状态           | ✅ 推荐无状态           | ✅ 推荐                 | Pod 无状态更易扩缩容，状态需外部存储 |
| 容器实例（ACI / Fargate / ECI）| ✅ 默认无状态        | ✅ 默认无状态          | ✅ 默认无状态           | ✅ 推荐                 | 每次任务是临时容器，任务完成即销毁 |
| Web 应用平台       | ⚠️ 有状态风险          | ⚠️ 有状态风险            | ⚠️ 有状态风险            | ❌ 中等推荐              | 默认无状态，但很多框架内建 Session / 缓存，需外部处理 |
| Kubernetes Pod     | ⚠️ 看你怎么写           | ⚠️ 看你怎么写             | ⚠️ 看你怎么写             | ✅（自己写成无状态）     | 本身支持无状态，但你写服务时常常“写出状态” |
| Batch 计算任务     | ✅ 无状态              | ✅ 无状态               | ✅ 无状态               | ✅ 推荐                 | 每个任务独立运行，结果需持久化到 Blob/S3/OSS |
| Serverless 函数    | ✅ 天生无状态           | ✅ 天生无状态            | ✅ 天生无状态            | ✅ 强烈推荐              | 每次调用是独立事件，完全 stateless（不信你试试存个值） |


我倾向于将应用设计为无状态，使得服务能够水平扩展，像容器服务和 serverless 是天然支持无状态的；而虚拟机和传统 Web App 平台则需要额外处理状态外置问题，比如 Redis、外部数据库或 Blob Storage。

## ☁️ 三大云平台 Compute 并发能力对比

| 服务类型 | Azure 并发支持 | AWS 并发支持 | 阿里云并发支持 | 是否推荐高并发场景 | 说明 |
|----------|---------------|--------------|----------------|--------------------|------|
| 虚拟机（VM / ECS） | ✅ 完全自定义并发（有状态/无状态均可） | ✅ 完全自定义并发（有状态/无状态均可） | ✅ 完全自定义并发（有状态/无状态均可） | ✅ 推荐 | OS 层/磁盘/内存可持久化，支持多线程/多进程/异步，适合自建高并发业务 |
| 容器实例（ACI / Fargate / ECI） | ✅ 支持并发（取决于容器内应用设计，无原生自动扩容） | ✅ 支持并发（取决于容器内应用设计，无原生自动扩容） | ✅ 支持并发（取决于容器内应用设计，无原生自动扩容） | ⚠️ 中等推荐 | 单实例可并发处理多个请求，但扩容需额外编排器/负载均衡，适合短期或临时计算任务 |
| 容器服务（Container App / App Runner / SAE） | ✅ 支持并发（默认 100 请求/实例，可配置，支持自动扩容） | ✅ 支持并发（可配置并发阈值，支持自动扩容） | ✅ 支持并发（可配置并发阈值，支持自动扩容） | ✅ 推荐 | 面向长时间运行的微服务，具备自动扩容和并发阈值控制能力 |
| Web 应用（App Service / Elastic Beanstalk / 函数计算 Web） | ✅ 支持并发（自动扩展线程池和实例数） | ✅ 支持并发（自动扩展线程池和实例数） | ✅ 支持并发（自动扩展线程池和实例数） | ✅ 推荐 | 适合 Web/API 场景，可根据负载自动扩缩容，需注意应用内状态存储 |
| Kubernetes 服务（AKS / EKS / ACK） | ✅ 支持并发（取决于 Pod 配置和服务架构，可用 HPA/VPA 自动扩容） | ✅ 支持并发（取决于 Pod 配置和服务架构，可用 HPA/VPA 自动扩容） | ✅ 支持并发（取决于 Pod 配置和服务架构，可用 HPA/VPA 自动扩容） | ✅ 推荐 | Kubernetes 原生支持水平扩容，结合应用架构可实现高并发 |
| Batch 服务（Azure Batch / AWS Batch / 阿里云批处理） | ✅ 支持大规模任务并发（百万级） | ✅ 支持大规模任务并发（百万级） | ✅ 支持大规模任务并发（百万级） | ✅ 推荐 | 适合分布式批处理计算，平台自动分配任务到计算节点 |
| 函数服务（Function / Lambda / 函数计算） | ✅ 支持并发（默认 100 并发/实例，可配置，自动扩容） | ✅ 支持并发（默认并发限制可调，自动扩容） | ✅ 支持并发（默认 100 并发/实例，可配置，自动扩容） | ✅ 推荐 | 事件驱动，平台自动扩容，按需收费，适合突发高并发场景 |

---
**参考文档**
   - [Azure Container Instances 概述](https://learn.microsoft.com/azure/container-instances/container-instances-overview)
   - [Azure Container Apps 并发与缩放](https://learn.microsoft.com/azure/container-apps/scale-app)
   - [Azure Functions 并发配置](https://learn.microsoft.com/azure/azure-functions/performance-reliability)




---

## 💡 说明

- **虚拟机类**：你想怎么并发就怎么并发，没人管你，但你要自己扛住。
- **容器实例类**：设计上是跑单个任务，轻量临时任务，不适合高并发请求。
- **容器服务类**：主力军，默认支持多请求处理，适合 Web/API 服务。
- **函数服务类**：
  - Azure Function / 阿里云函数：支持函数内并发（默认约 100）
  - AWS Lambda：**单实例处理单请求**，扩容靠加实例（scale-out）

---

## ✅ 总结：你该怎么选

- 要跑多个请求同时处理 → **Web App / Container App / Kubernetes**
- 要大规模并发任务 → **Batch 系列**
- 要最大灵活性 + 自己掌控线程数 → **虚拟机**
- 只执行一个任务就走 → **容器实例**
- 需要低成本轻量化任务处理 → **函数服务（Function/Lambda）**

