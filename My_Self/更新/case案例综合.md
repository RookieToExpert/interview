## 印象深刻的案例？
#### 技术板块(迁移时high churn issue)
#### 性能
**S**：之前对接过一个客户，因本地数据中心到期，需通过 Azure migrate 工具以 lift-and-shift 方式，将几十台服务器迁移至云端 Azure VM。前期链路搭建顺畅，然而在增量备份阶段，有几台 MySQL 服务器数据同步失败，云端报错 “High churn issue limit”，提示磁盘 IO 超限。

T：作为技术对接工程师，核心任务是找到具体数据同步出错的根因，并且给出客户可接受的一个解决方案。

**A**：
- 确认报错：通过后台查看后端日志以及搜去本地sql服务器的代理日志，确认报错信息和portal端一致。

- 定位root cause：随后与客户约定时间，远程接入本地环境，通过```iostat -dx 600 3```以及查看`/proc/diskstats`日志查看磁盘平均每秒写入的数据量和单次写入操作的平均大小：

    ![alt text](image-12.png)

    得到两个指标，一个是`wareq-sz`(write request size)表示平均写 I/O 大小（单位 KB），结合`wkB/s`(write KB per second)可以得到每秒平均写入的总KB，上图则是`wkB/s` = 8543.60 → ≈ 8.34 MB/s,`wareq-sz` = 17 KB。结合两个指标，对比云端的磁盘IOPS的支持表格：

    ![alt text](image-13.png)

    > 通常迁移云端默认使用standard磁盘作为接受对象，软这边磁盘分为两种，standard HDD和preimum SSD，HDD能接受每秒256次IOPS，SSD根据磁盘大小通常是1280次IOPS到2560次IOPS左右，那么根据单次IOPS的大小，通常数据库的话PGsql默认是8KB一个page，mysql innoDB默认是16KB一个page，那么我们会有一个官方的支持表格根据接收磁盘的每秒的IOPS数量和大小可以得到一个每秒的写操作大小的上限。所以大概率是无法承受数据库，日志类型的服务器这种写入量操作非常频繁的服务器。

- 结合根因和最佳实践，我们给出客户的方案是将云端的replica disk类型调整为premium大小，但是由于这个调整会需要客户将当前的blob存储和接收磁盘类型都换成premium的规格，premium规格的blob存储每GB的价格是standard的十倍，SSD disk的规格和相同大小的HDD disk整体价格也是4倍左右，当时客户的迁移buget是比较紧张的，所以客户当下其实是不太愿意去做这个更改，并且还压力我们说是我们不想解决问题，只想着多收钱。

- 但客户拒绝升级，我没有僵持，我是想到我们内部 DMS 可单独迁移数据库，且适配高 IO 场景。虽然我们并不负责DMS的产品，但我立刻联系 DMS 团队的TA，同步客户的 “MySQL 5.7、80GB 数据、停机＜15 分钟” 需求，拉通三方会议：DMS 团队设计 “binlog 实时同步 + 增量切换” 方案。沟通时，我用成本表说服客户：DMS迁移相比服务器迁移，中间不需要去建立多余的中转资源；且长期用 paas的DB自带的高可用、备份及底层的运维从长远来看是能减少更多的成本。同时承诺全程盯测试和迁移，消除他的顾虑。

**R**：最终客户选择通过DMS的方式去迁移，所有数据库服务器迁移成功，数据零丢失，停机页控制在分钟级，从长远来看客户的如果使用paas sql的成本肯定也会更低。客户非常满意，并且后续开case还一直指名要我去对接。


#### 网络
S：客户本地的数据中心，希望通过ASR进行异地容灾备份到Azure，但是在初次同步的时候一直卡在初次同步阶段，报错“ErrorCode: 33007, ErrorMessage: Failed to connect to the source server. Verify that the source server is reachable from the configuration server and that the credentials are correct.”。客户本地网络环境比较复杂，且对网络安全要求较高，不允许直接开放所有端口。

T：排查网络问题，找出root cause并且给出客户满意的解决方案。

A：
- 确认报错：通过后台查看后端日志以及搜去本地配置服务器的代理日志，确认报错信息和portal端一致。

- 定位root cause：
    - 确认网络环境：还是和客户约定时间，了解客户的本地网络环境，查看是否有代理服务器，防火墙设备，是否使用了private endpoint等更细节的网络拓扑图，确保代理服务器和防火墙设备都将所有需要访问的共有节点进行放行，白名单，客户确认已经做好了这一步，并且我们也二次检查，确保所有的端口都已经放行。
    - 到source VM上，通过`ss -tuna | grep 9443`命令检查端口监听情况，看是否有到迁移服务器的9443TCP连接已被建立，发现没有找到任何连接，继续通过`telnet <config server ip> 9443`命令测试，发现无法telnet通，说明网络层面存在问题。
    - 进一步我们怀疑防火墙没有开放9443端口，进一步去排查，发现客户的防火墙设备是有做端口白名单的，并且9443端口并不在白名单中，导致无法访问。给出方案，将端口白名单，再重新去source VM进行`telnet <config server ip> 9443`测试，发现可以telnet通，但是整体数据同步任然失败，此时我们确认source到appliance这里是联通了。
    - 我们进一步去到appliance上，确认appliance和source能互通，那此时就是appliance无法访问ASR的节点，客户本地使用的是site-to-ste VPN连接到的时候ASR的私有节点，进一步我们先检查客户是否能正常域名解析这些ASR节点，发现nslookup timeout，说明客户的DNS服务器无法解析这些域名，此时我们提供了几个方案给客户：
        1. 在azure中建立建立一台dns服务器，将私有dns zone绑定到vnet中，然后在本地的dns服务器上配置转发规则，将这些asr的域名转发到azure中的dns服务器上去解析。
        2. 直接使用azure dns resolver(一个paas服务)，在本地的dns服务器上配置转发规则，将这些asr的域名转发到azure dns resolver上去解析。
        3. 直接在本地的dns服务器上添加这些asr节点的域名和ip的映射关系。
    - 客户在最终选择了第三种方案，因为private endpoint并不多，所以直接添加映射关系是最简单粗暴的方式。
    - 此时域名解决了之后，还是连接不上，我们怀疑VPN的路由没有配置正确，我们联系了网络组的TA，共同来排查问题，最后发现azure VPN gateway绑定的Vnet和私有dns zone绑定的vnet不一致，导致无法访问这些私有节点，所以我们重新绑定以后，问题解决。
> site to site VPN通过IKEv2(负责建立安全关联（SA），协商密钥、加密算法)和IPSec ESP(负责加密数据包，保证机密性和完整性)协议实现通信。
#### 内核