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
    - Deployment: 是一种用于管理Pod副本的资源对象，它可以实现Pod的滚动更新、回滚等功能。通过指定Deployment的副本数量，K8S会自动创建和管理相应数量的Pod副本，并确保它们的状态与配置一致。
    - StatefulSet：用于管理有状态的应用，如数据库等。与Deployment不同，StatefulSet中的每个Pod都有唯一的网络标识和持久化存储，并且在Pod重新调度时会保留其状态。
    - DaemonSet：确保在集群中的每个节点（或指定的节点）上都运行一个Pod副本。常用于运行系统级的守护进程，如日志收集、监控代理等。
- 服务发现和负载均衡资源对象
    - Service：为一组Pod提供统一的网络访问入口，实现了服务发现和负载均衡功能。Service可以通过ClusterIP、NodePort、LoadBalancer等不同的类型暴露给外部或内部客户端访问。
    - ingress：是一种用于管理外部对集群内部服务的访问规则的资源对象。它可以根据HTTP/HTTPS请求的域名、路径等信息将请求转发到不同的Service，实现了基于域名和路径的路由。
- 存储资源对象
    - PersistentVolume（PV）：是集群中的存储资源，它是独立于Pod的存储抽象。PV可以是NFS、iSCSI、Ceph等不同类型的存储，为Pod提供持久化存储。
    - PersistentVolumeClaim（PVC）：是用户对存储资源的请求，它与PV进行绑定，为Pod提供具体的存储卷。PVC可以根据存储的大小、访问模式等要求动态分配PV。
