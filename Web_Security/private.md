1. 什么是Azure Private Link？为什么企业要使用它？
概念：Azure Private Link(私有链接)允许你把Azure平台服务(如Azure Storage、Azure SQL、Azure Synapse等)或者你自己的服务暴露在Azure内部的VNet专用IP地址上，从而实现“私网访问”而不走公用Internet。
好处：
安全合规：数据流量完全在Azure骨干网内传输，无需公网暴露。
降低风险：减少公网防火墙配置与攻击面，增强企业安全。
统一网络策略：可与Azure Network Security Group (NSG)或自定义路由结合，方便统一管理。
可搜索关键字：

“Azure Private Link Overview”
“Azure Private Endpoint”
2. 假设从公司内网通过Azure Private Link连接到Snowflake在Azure上的VNet，流量怎么走？
公司内网 -> Azure VNet：
公司内网通过Site-to-Site VPN或ExpressRoute连接到Azure VNet。
在VNet中创建Private Endpoint：
管理员在Azure VNet的子网中，为Snowflake服务创建一个Private Endpoint（注：Snowflake在Azure上支持PrivateLink/Private Endpoint模式）。
DNS配置：
为Snowflake的域名（类似account1234.snowflakecomputing.com）配置私有DNS记录，指向分配给Private Endpoint的私有IP。
流量路由：
当客户端在公司内网访问Snowflake的域名时，解析到Azure VNet中的私有IP，然后流量通过VPN/ExpressRoute进入VNet，再通过Private Endpoint到达Snowflake服务。
全程内网：
数据包未离开Azure专用网络+企业自有网络，不会经过公共Internet。
可搜索关键字：

“Configure a Private Endpoint to Snowflake in Azure”
“Azure Private Endpoint DNS configuration best practices”
