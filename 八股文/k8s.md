1. kubernetes的基本组件及功能？
- master node
    - kube-apiserver:作为Kubernetes API的前端，提供了RESTful风格的API接口，是各个组件沟通的枢纽，负责认证、授权、准入控制等操作。
    - etcd：一个高可用的分布式键值存储系统，作为Kubernetes集群的唯一数据源，存储集群的所有配置信息和状态数据。提供了数据的持久化存储和分布式一致性保证，确保在集群中的多个节点之间数据的一致性和可靠性。
    - kube-scheduler：根据节点的资源可用性、Pod的资源请求、节点的亲和性和反亲和性等策略，对所有可用节点进行评估和筛选，选择最优的节点来运行Pod。
    - kube-controller-manager：是一组控制器的集合，每个控制器负责管理集群中特定类型的资源，确保集群的状态始终符合用户定义的期望状态。

        ![alt text](image-19.png)

    - cloud-controller-manager(optional)：与云服务提供商的API进行交互，将与云平台相关的控制逻辑从主控制平面中分离出来。允许Kubernetes与不同的云服务提供商（如AWS、GCP、Azure等）集成，实现云资源的管理和调度，如弹性IP、负载均衡器等。
- worker node
    - kubelet：作为节点上的代理，负责与控制平面进行通信，接收和执行控制平面下发的任务比如管理节点上的Pod和容器的生命周期，监控容器的资源使用情况，并将节点和容器的状态信息反馈给控制平面。
    - kube-proxy：在每个节点上运行，负责实现Kubernetes服务的网络代理和负载均衡功能，为服务创建和维护网络规则，将服务的请求转发到对应的Pod上，实现服务的外部访问和内部通信，支持多种代理模式，如用户空间代理模式、IPVS代理模式等。
    - Container Runtime：负责在节点上运行和管理容器，是容器化应用程序的运行环境，Kubernetes支持多种容器运行时，如Docker、Containerd、CRI-O等，这些容器运行时通过容器运行时接口（CRI）与Kubernetes进行交互。

        ![alt text](image-20.png)

2. 详细说明K8S的架构和资源对象。
- 核心资源对象：
    - Pod:是K8S中最小的可部署和管理的计算单元，一个Pod可以包含一个或多个紧密相关的容器。Pod中的容器共享网络命名空间和存储卷，它们可以通过localhost进行通信，并且可以访问共享的存储。
    - Node:表示K8S集群中的一个工作节点，可以是物理机或虚拟机。
    - Namespace:用于将集群资源划分为不同的逻辑组，不同的Namespace之间相互隔离。可以在不同的Namespace中创建同名的资源对象，常用于多租户环境或不同项目的资源隔离。
- 工作负载资源对象
    - Deployment: 是一种用于管理Pod副本的资源对象，它可以实现Pod的滚动更新、回滚等功能。它为 Pod 和 ReplicaSet 提供了声明式的更新能力，通过指定Deployment的副本数量，K8S会自动创建和管理相应数量的Pod副本，并确保它们的状态与配置一致。
    - StatefulSet：用于管理有状态的应用，如数据库等。与Deployment不同，StatefulSet中的每个Pod都有唯一的网络标识和持久化存储，并且在Pod重新调度时会保留其状态。
    - DaemonSet：确保在集群中的每个节点（或指定的节点）上都运行一个Pod副本。常用于运行系统级的守护进程，如日志收集、监控代理等。
- 服务发现和负载均衡资源对象
    - Service：为一组Pod提供统一的网络访问入口，实现了服务发现和负载均衡功能。Service可以通过ClusterIP、NodePort、LoadBalancer等不同的类型暴露给外部或内部客户端访问。
    - ingress：是一种用于管理外部对集群内部服务的访问规则的资源对象。它可以根据HTTP/HTTPS请求的域名、路径等信息将请求转发到不同的Service，实现了基于域名和路径的路由。
- 存储资源对象
    - PersistentVolume（PV）：是集群中的存储资源，它是独立于Pod的存储抽象。PV可以是NFS、iSCSI、Ceph等不同类型的存储，为Pod提供持久化存储。
    - PersistentVolumeClaim（PVC）：是用户对存储资源的请求，它与PV进行绑定，为Pod提供具体的存储卷。PVC可以根据存储的大小、访问模式等要求动态分配PV。

    **2.1.**：Kubernetes里的Service、Deployment、Pod、StatefulSet分别是什么

    - Service：为一组Pod提供统一的网络访问入口，实现了服务发现和负载均衡功能。
        - ClusterIP：默认类型，在集群内部创建一个虚拟 IP，只能在集群内部访问。
        - NodePort：在每个节点上开放一个端口，通过节点的 IP 地址和该端口可以从集群外部访问服务。
        - LoadBalancer：使用云提供商的负载均衡器将流量分发到服务，适用于公有云环境。
        - ExternalName：将服务映射到外部的 DNS 名称，用于将集群内的服务与外部服务进行关联。

    - deployment: 是一种用于管理Pod副本的资源对象，它可以实现Pod的滚动更新、回滚等功能。它为 Pod 和 ReplicaSet 提供了声明式的更新能力，通过指定Deployment的副本数量，K8S会自动创建和管理相应数量的Pod副本，并确保它们的状态与配置一致。
        - 自动伸缩：可以根据业务需求调整 Pod 的副本数量，以应对不同的负载。
        - 滚动更新：在更新应用版本时，Deployment 可以逐步替换旧的 Pod 实例，确保服务的连续性。
        - 回滚：如果更新过程中出现问题，可以快速回滚到之前的版本。
    
    - pod：是K8S中最小的可部署和管理的计算单元，一个Pod可以包含一个或多个紧密相关的容器。Pod中的容器共享网络命名空间和存储卷，它们可以通过localhost进行通信，并且可以访问共享的存储。

    - statefulset：StatefulSet 是 Kubernetes 中用于管理有状态应用的工作负载资源。与 Deployment 管理的无状态应用不同，有状态应用通常需要保留一些持久化的数据，并且每个实例都有唯一的标识。
        - 稳定的网络标识：每个 Pod 都有一个唯一的、稳定的网络标识（主机名），可以通过该标识进行访问。
        - 有序部署和扩展：Pod 按照顺序依次创建和删除，确保应用的状态正确。
        - 持久化存储：StatefulSet 可以为每个 Pod 关联一个持久化存储卷，保证数据的持久化。

3. K8s创建pod的详细流程？
- kubectl → API Server: 用户通过kubectl工具与API Server通信。
- API Server ↔ etcd: API Server与etcd进行数据存取。
- Controller ↔ API Server: watch 到新的 Deployment → 调用 API Server 创建 ReplicaSet/Pod 对象
- API Server ↔ Scheduler: Scheduler从API Server中拉取调度信息。
- Scheduler ↔ API Server: 更新Pod的调度状态。
- API Server ↔ Kubelet: Kubelet拉取Pod信息，并上报状态。
- Kubelet ↔ 容器运行时: Kubelet指示容器运行时启动和管理容器。
- Pod ↔ Service: Pod通过Service进行负载均衡和服务发现。


4. 在k8s中，如何进行日志和监控的管理
- 综合解决方案：
    - ELK Stack (Elasticsearch, Logstash, Kibana)：用于日志的收集、存储和可视化。
    - EFK Stack (Elasticsearch, Fluentd, Kibana)：Fluentd 替代 Logstash 来做日志收集。
    - Prometheus + Grafana：用于监控和可视化。
- 最佳实践：
    - 日志等级管理：合理设置应用程序的日志等级，可以帮助管理存储和提升日志的查找效率。
    - 记录重要事件：务必将关键事件、错误消息和异常情况进行详细记录。
    - 数据保留策略：设置日志和监控数据的保留策略，以平衡存储成本和历史数据的可用性。
    - 安全性：确保日志和监控数据的访问控制，以保护敏感信息。

5. 当pod出现问题，如何进行排查？
    1. 确认 Pod 状态：`kubectl get pods -n <namespace>`
    2. 查看 Pod 详细信息：`kubectl desribe pod <podname>`
    3. 检查容器日志：`kubectl logs <podname>`
    4. 检查资源限制和请求：`kubectl get pod <podname> -o yaml`
    5. 检查网络配置：
    - `kubectl get pods -o wide` 
    - `kubectl get networkpolicies` 
    - `kubectl -exec -it <podname> -- ping <ip>` or `kubectl -exec -it <podname> -- curl <url>`

        ![alt text](image-22.png)

    6. 检查存储配置：`kubectl describe pod <porname>`

        ![alt text](image-23.png)

    7. 检查节点状态：`kubectl get node <nodename>` or `kubectl desribe node <nodename>`
    8. 检查核心api组件的命令：
    - 是否存活：
        ```bash
        ps -ef | grep kube-apiserver        # 二进制部署
        kubectl -n kube-system get pods | grep apiserver
        ```
    - 健康检查：用systemctl或者curl去测试是否正常运行
        ```bash
        curl -k https://127.0.0.1:6443/heathz
        curl -k https://127.0.0.1:6443/livez
        curl -k https://127.0.0.1:6443/readyz?verbose
        systemctl status kubelet -l
        ```
    - 日志排查：
        ```bash
        journalctl -u kube-apiserver -f
        journalctl -u kubelet -xe
        journalctl -u kubelet -xe
        kubectl -n kube-system logs kube-apiserver-<node-name>
        crictl ps -a | grep etcd
        crictl logs <etcd-container-id> 
        ```
    9. 检查 RBAC 配置：
        ```bash
        kubectl get serviceaccounts
        kubectl get roles
        kubectl get rolebindings
        ```

6. 请介绍Kubernetes的三种探针
    - 存活探针（livenessProbe）:判断容器是否“活着”
        - 工作流程：
            - Pod 启动 10 秒后（initialDelaySeconds: 10），kubelet 开始检查。
            - 每隔 5 秒（periodSeconds: 5）发一次 HTTP 请求：http://<pod-ip>:8080/healthz。
            - 如果返回 200-399 → 健康；否则认为容器“挂了”。
            - 失败时 kubelet 会重启容器。

    - 就绪探针（readinessProbe）:判断容器是否“准备好接收流量”。
        - 工作流程：
            - Pod 启动 5 秒后，kubelet 开始检查。
            - 每隔 10 秒 尝试建立 TCP 连接到容器的 3306 端口。
            - 如果能连通 → Pod 被标记为 Ready，会被加到 Service 的 endpoints。
            - 如果失败 → Pod 标记为 NotReady，Service 不会把流量转给它。

    - 启动探针（startupProbe）:专门为“慢启动应用”设计，避免启动阶段被误杀。
        - 工作流程：
            - kubelet 每隔 10 秒执行一次 cat /tmp/ready。
            - 最多允许失败 30 次 → 也就是最多给 5 分钟启动时间。
            - 在 startupProbe 成功之前，不会执行 livenessProbe 和 readinessProbe。
            - 如果一直失败 → kubelet 会杀死容器并重启。  

        ![alt text](image-24.png)

        ![alt text](image-25.png)

7. K8s的网络插件有哪些？
- Calico(192.168.0.0/16 或 10.244.0.0/16)：
    - 特点：基于BGP（边界网关协议）的网络插件，支持网络策略。它提供了细粒度的网络访问控制，能够根据标签对Pod之间的流量进行过滤和隔离，增强了集群的安全性。
        - 每个 Node 节点上都会运行一个 BGP Daemon（BGP client），最常见的是 Bird 或 GoBGP。
        - 这个 BGP Daemon 负责：
            1. 把本节点的 Pod 网段（比如 10.244.1.0/24）通过 BGP 协议宣告出去
            2. 学习其他节点宣告的 Pod 网段（比如 Node2 的 10.244.2.0/24）
            3. 更新本机路由表（Linux 内核的路由表）

                ![alt text](image-26.png)

    - 应用场景：适用于对网络安全要求较高的企业级应用场景，如金融、医疗等行业的K8S集群。
- Flannel(10.244.0.0/16)：
    - 特点：特点：简单易用，是K8S中最常用的网络插件之一。它通过在各节点之间创建虚拟网络，实现Pod之间的通信。支持多种后端模式，如VXLAN、UDP等。
    - 应用场景：适合初学者或者对网络性能要求不是特别高的测试、开发环境。

- Cilium(10.0.0.0/8)：
    - 特点：基于 eBPF（内核层编程），高性能、支持网络策略、Service Mesh、透明加密
    - 应用场景：金融、AI/高性能场景，新趋势。

8. 简述Kubernetes Pod的常见调度方式?
1. 默认调度：Kubernetes使用默认的调度器（kube-scheduler）来根据资源需求和节点的可用资源进行调度。调度器会评估节点的CPU、内存等可用资源。
2. 亲和性和反亲和性：
    - 节点亲和性（Node Affinity）：根据**节点的标签**将Pod调度到特定的节点。

        ![alt text](image-27.png)

        查看节点的标签：`kubectl get nodes --show-labels`

        ![alt text](image-31.png)

    - Pod亲和性（Pod Affinity）：将Pod调度到与特定Pod在同一节点上。

        ![alt text](image-28.png)

    - Pod反亲和性（Pod Anti-Affinity）：避免将Pod调度到与特定Pod在同一节点上。

        ![alt text](image-29.png)

3. 污点和容忍(taint和tolerant)：节点可以设置污点，表示该节点不接受特定类型的Pod。Pod可以设置容忍，以便能够被调度到有污点的节点上。
    - 查看节点的taint：`kubectl describe node <node name> | grep Taints`

        ![alt text](image-30.png)

        ![alt text](image-33.png)

    - 要将pod调度到有taint的节点，需要写上tolerant：

        ![alt text](image-32.png)

4. 资源请求和限制：Pod可以声明所需的资源（CPU、内存等），调度器会根据节点的可用资源做出调度决策。

    ![alt text](image-34.png)

    ![alt text](image-35.png)

5. 优先级和抢占：Kubernetes支持Pod优先级，使得高优先级的Pod可以抢占低优先级的Pod以获取资源。

    ![alt text](image-36.png)

    ![alt text](image-38.png)

6. 分布策略：通过配置分布策略，可以控制Pod在集群中的分布情况，防止集中在某个节点上。

    ![alt text](image-39.png)

7. 定制调度器：用户可以创建自定义调度器，处理特定的调度逻辑，以满足业务需求。
8. 地点亲和性（Topological Spread Constraints）：控制Pod在集群不同拓扑（如不同地区、区域等）的分布，以提高可用性和容错性。