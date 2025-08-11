## azure sql server vm
完整的SQL server，需要自行管理OS和SQL server的版本更新。

**Availability group:**
- 主节点 (primary) + 一个或多个副本 (secondary)
- 所有节点都有自己的存储（不共享存储），靠日志传输保持数据同步。
- 可以在副本之间自动或手动故障转移。
- 某些副本还能做只读查询（做 reporting 或 offload 查询压力）。

**Failover cluster:**
- 多个节点共用一个共享存储（比如 Storage Spaces 或 Premium File Share）。
- 一个节点挂了，另一个节点接管服务（但挂的是 IP 和服务，磁盘还在共享处）。
- 整个 SQL Server 实例 failover，进程级别的接管。

**VNN(Virtual Network Name):**
- 在传统 FCI 或 AG 中，VNN 是客户端连接的统一名称。
- 它对应一个浮动 IP 地址，根据当前主节点在哪台机子上，IP 就漂过去。
- 本地网络喜欢玩这个，DNS 刷新很快。

**DNN(Distributed Network Name):**
- DNN 是 SQL Server 2017+ 支持的Azure 原生可用的 Listener 替代品。
- 不用浮动 IP，不用负载均衡器，完全靠 DNS 做 name resolution。
- 每个节点都有自己的 IP，不需要漂移，但客户端连接时知道怎么找“现在谁是老大”。