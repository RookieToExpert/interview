    1. 如何查看端口是否被占用？
- `lsof -i :80` (可以更详细地显示进程信息)
- `ss -tunpa | grep 80` (则更高效，适合在大规模系统中使用)

![alt text](image-9.png)

2. 如何排查资源使用情况？
- `vmstat` (r很高(> CPU 核心数) → CPU 不够，si/so 大量交换(持续不为 0) → 内存不足，b 很高(长期大于 CPU 核心数的 20–30%)、wa 高(> 20%：磁盘 I/O 瓶颈明显) → 可能 I/O 瓶颈。)

    ![alt text](image-10.png)

- `iostat` (看idle时间，看磁盘的平均单次I/O平均大小和I/O平均大小)

    ![alt text](image-11.png)

- `htop` (看实时系统cpu，内存及正在运行的进程的情况)

    ![alt text](image-12.png)

- `df -h`（看磁盘使用情况）

    ![alt text](image-13.png)

- `free`（看内存使用情况）

    ![alt text](image-14.png)

    **2.1** 若top命令后看到一个进程使用率为100%，如何分析问题，在什么情况下会出现这种情况
    - 看htop中该进程的cpu,内存(RES物理内存和VIRT虚拟内存)的使用情况
    - 通过iostat命令查看**磁盘的I/O使用情况**，使用 **iotop 命令查看具体的磁盘I/O占用进程**，判断该进程是否存在大量的磁盘读写操作。
    - 使用 netstat 或 ss 命令**查看网络连接情况**，使用 **iftop 命令查看网络流量情况**，判断该进程是否存在大量的网络数据传输。
    - 分析源代码，查看代码中是否存在死循环、递归调用过深等问题。
    - 查看**系统日志**/var/log/syslog 或 /var/log/messages，判断是否有相关的错误信息。
    - 常见问题：死循环，高并发处理，资源竞争，系统配置问题。
3. 如何查看日志？
- `journalctl -u kubelet` (用于查看systemd-journald服务收集的日志)

    ![alt text](image-15.png)

4. 什么是硬链接软连接？
- 硬链接是直接与文件数据关联，不能跨分区且不可以链接目录，不占用inode。(``ln sourcefile linkfile``)
- 软链接是对文件路径的引用，可以跨分区且可以链接目录，占用inode，删除源文件会导致软链接变成悬挂链接，无法访问目标文件(`ln -s sourcefile linkfile`)。

5. 进程和线程的区别？
- 定义：进程是程序在**操作系统中的一次执行过程**，是系统进行**资源分配和调度的基本单位**。**线程是进程中的一个执行单元**，是**CPU调度和分派的基本单位**。
- 资源占用：进程拥有自己**独立的内存空间、系统资源**（如文件描述符、信号处理等）。一个进程可以包含多个线程，这些线程**共享该进程的内存空间和系统资源**。
- 调度和执行：线程和进程的调度**都由操作系统内核负责**，但线程的调度开销通常比进程小，因为线程之间的切换不需要切换内存空间。
- 通信方式：进程之间的通信（IPC）通常需要使用**管道、消息队列、共享内存等机制**，而线程之间可以直接通过**共享变量进行通信**，因为它们共享同一进程的内存空间。
- 健壮性：进程之间的独立性使得一**个进程的崩溃不会影响到其他进程**，因此进程的健壮性较高。由于线程共享所在进程的内存空间，**一个线程的崩溃可能会导致整个进程的崩溃**，因此，线程的健壮性相对较低。

    **5.1** 怎么杀死进程？

        ![alt text](image-16.png)

    **5.2** Linux如何查询端口并杀死进程？
        - 通过ss或者Isof查询到对应端口进程的PID，并执行kill或者kill -9杀死进程。

    **5.3** 进程如何通信？
    - 管道（Pipe）/命名管道（FIFO）
        - 底层：基于pipe(),mkfifo()实现
        - 具体：ls | grep txt 或者 mkfifo /tmp/fifo && cat /tmp/fifo & echo hello > /tmp/fifo
    - 消息队列（Message Queue）
        - 底层：开发可以直接用msgsnd/msgrcv系统调用
        - 应用层：通常用常见中间件包括RabbitMQ, Kafka, ActiveMQ实现。
    - 共享内存（Shared Memory）
        - 数据库（MySQL、PostgreSQL）大量用共享内存来做 buffer pool。
    - 信号（Signal）
        - 底层：kill()实现。
        - 具体：kill -9 PID、Ctrl+C（SIGINT）就是最直观的表现。
    - 套接字（Socket）
        - 具体：网络编程的基础，TCP/IP、UDP 都是 socket 的应用。
    - 文件映射（Memory-Mapped Files）
        - 用于加速文件访问，例如 Linux 下的 mmap，可以让文件内容直接表现为内存数组。

6. 在linux中，输入一个命令后，会发生什么？
- **命令解析**：
    - 用户在终端输入命令后，终端程序比如bash，sh会读取用户的整行输入，并且进行**分行处理，区分命令本身，选项和参数**。
    - 终端会判断输入的命令是是**内置命令、外部命令还是别名**。
- **命令查找**
    - 内部命令：shell会直接调用内部的函数来执行该命令。
    - 外部命令：查找当前**环境变量中的PATH**指定的目录列表。
    - 别名：shell会将其替代成对应的实际命令。
- **环境准备**
    - **变量替换**：例如输入`echo $HOME`的时候，shell会将其中HOME替换成为用户主目录的实际路径。
    - **通配符拓展**：输入`ls *.txt`，shell会将*.txt扩展为当前目录下所有以.txt结尾的文件
    - **命令替换**：例如输入`echo(date)`，shell会先执行`date`，再替换掉`(date)`的位置，然后再执行echo。
-**进程创建与执行**
    - 对于外部命令，shell会调用**fork()**系统调用创建一个新的子进程，子进程创建成功后，会调用**exec()**系列系统调用，用要执行的命令对应的可执行文件替换当前子进程的映像。
- **输入输出处理**
    - 标准输入、输出和错误输出
    - 重定向
    - 管道
- **结果返回与状态码**
    - 命令执行结果
    - 退出状态码

7. linux中(), (()), {}, [], [[]]的区别： 

![alt text](image-17.png)

8. 再linux中，如何查找一个文件？
- find
- locate(推荐locate)

    **9.1** 如何查看文件或者目录大小？
    - `ls -l`
    - `du -sh 文件或目录名` (显示文件或目录的总大小，s表示总结，h表示以人类可读的格式显示)
    - `df -h` (显示文件系统的磁盘使用情况)
    - `stat 文件或目录名` (显示文件或目录的详细信息，包括大小、权限、所有者等)

        ![alt text](image-69.png)

        ![alt text](image-70.png)

9. 通常linux中，有哪些查看网络状态的命令？
- IP: ip命令是ifconfig的替代工具，功能更强大，可用于显示和配置网络接口、路由表等信息。
- ss: ss是netstat的替代工具，速度更快，能提供更详细的网络连接信息。
- ping：用于测试网络连通性，向目标主机发送ICMP回显请求数据包，并接收目标主机的响应。
- telnet：用于测试 TCP 端口连通性，常用于验证目标主机某个服务端口是否可访问。
- curl：用于从命令行发送 HTTP/HTTPS 请求，调试 Web 服务常用。
- traceroute：用于跟踪数据包从本地主机到目标主机所经过的路由路径
- tcpdump：用于捕获和分析网络数据包，常用于网络故障排查和安全分析。

10. linux中的通道是什么？
- 匿名通道：
`ls | grep xxx`
- 命名通道：

    ![alt text](image-18.png)

11. 了解文件系统类型吗？
- 文件系统类型：
    - Ext4：是Linux系统中广泛使用的日志文件系统，它是Ext3文件系统的后继版本。具有高可靠性、高性能和良好的扩展性，支持最大1EB的文件系统和最大16TB的单个文件，同时还支持延迟分配、多块分配等特性，能有效提升文件系统的性能。
    - XFS：是一种高性能的64位日志文件系统，特别适合处理大容量数据和大文件。它具有出色的并发性能和快速的文件系统修复能力，在大规模数据存储和高性能计算环境中应用广泛。
- 文件系统工作原理：
    - inode：每个文件和目录在文件系统中都有一个对应的inode（索引节点），inode包含了文件的元数据，如文件的权限、所有者、文件大小、创建时间、修改时间等，同时还包含了指向文件数据块的指针。
    - 数据块：文件的数据实际存储在数据块中，数据块是文件系统分配和管理磁盘空间的基本单位。
    - 目录项：目录也是一种特殊的文件，它包含了一系列的目录项，每个目录项记录了文件名和对应的inode号码，通过目录项可以将文件名和inode关联起来。
- 文件系统的挂载与卸载


12. Linux内核是什么？
- 定义：Linux 系统的核心是内核。内核控制着计算机系统上的所有硬件和软件，在必要时分配硬件，并根据需要执行软件：
    - 系统内存管理
    - 应用程序管理
    - 硬件设备管理
    - 文件系统管理

13. 在Linux日志文件中如何查找关键字
- grep：
    - `grep "关键词" 日志路径` (可以加-i不区分大小写，-n显示行号，-r目录下递归查询)
    - `xxx | grep "关键词"` (管道符前的命令输出结果中查找关键词)
- sed：
    - `sed 's/foo/bar/g' file.txt`，将文件中的foo替换为bar(加上-i直接对原文本进行修改)
    - `sed -n '10,20p' file.txt`，打印第10到20行
    - `sed '/pattern/d' file.txt`，删除包含pattern的行
- awk：
    - `awk '{print $1, $3}' file.log`,打印特定列
    - `awk '$3 > 100 {print $0}' file.log`,按条件过滤，输出第3列大于100的行
    - `awk -F',' '{print $2}' data.csv`，指定分隔符为逗号，打印第2列
    - `awk '/error/ {print $0}' file.log`，结合正则表达式，查找包含"error"的行

14. 如何在两个服务器之间传送数据？
- scp：基于**SSH协议**的文件传输工具，适用于在两台Linux服务器之间安全地**复制文件和目录**。
    - 语法：`scp [选项] [源路径] [目标路径]`
    - 示例：`scp /path/to/local/file user@remote_host:/path/to/remote/directory`
- rsync： 基于**rsync协议**，支持**增量传输和断点续传**，适用于在两台服务器之间**同步文件和目录**。
    - 语法：`rsync [选项] [源路径] [目标路径]`
    - 示例：`rsync -avz /path/to/local/directory/ user@remote_host:/path/to/remote/directory/` (a表示归档模式，v表示详细输出，z表示压缩传输)
- ftp/sftp：基于**FTP协议**，适用于在两台服务器之间传输文件。**sftp是基于SSH的安全文件传输协议**，需要两台服务器都安装有FTP或SFTP服务。
    - ftp语法：`ftp [选项] [远程主机]`
    - sftp语法：`sftp [选项] [用户@远程主机]`
    - ftp示例：`ftp remote_host`，然后使用`ftp>`提示符下的通过**put** /home/user/test.txt上传文件，**get** test.txt下载文件。
    - sftp示例：`sftp user@remote_host`，然后使用`sftp>`提示符下的通过**put** /home/user/test.txt上传文件，**get** test.txt下载文件。

15. Linux中如何设置定时任务?
- 定义：使用cron服务来管理和执行定时任务。cron服务会定期检查crontab文件，并根据其中的时间表执行相应的命令或脚本。
- 编辑crontab文件：使用`crontab -e`命令打开当前用户的crontab文件进行编辑。
- crontab文件格式：每行表示一个定时任务，格式如下：
```* * * * * command_to_execute```
    - 五个星号分别表示分钟、小时、日期、月份和星期几，可以使用具体的数值、逗号分隔的列表、范围或步长来指定时间。
    - 例如，`0 2 * * * /path/to/script.sh`表示每天凌晨2点执行`/path/to/script.sh`脚本。
- 通过`crontab -l`查看当前用户的定时任务，通过`crontab -r`删除当前用户的定时任务。

16. shell脚本第一行是什么？
- 定义：在shell脚本的第一行通常会包含一个特殊的注释行，通常以#!/bin/bash开头，称为shebang（#!），用于指定脚本的解释器。

17. 在服务器上仅开启22端口和443端口，其他端口全部禁止访问，使用iptables如何实现。
- 仅允许22端口和443端口的入站流量(其中-A表示添加规则，-p表示协议，--dport表示目标端口，-j表示目标动作)：
```bash
# optional，避免冲突，可以先清空现有规则：
iptables -F             # 清空所有规则
iptables -X             # 删除所有自定义链
iptables -Z             # 清空所有计数器
# 开放22和443入站流量
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
# 拒绝其他所有入站，转发流量：
iptables -A INPUT -j DROP
iptables -A FORWARD -j DROP
# 允许所有出站流量：
iptables -A OUTPUT -j ACCEPT
# 允许本地回环接口流量：
iptables -A INPUT -i lo -j ACCEPT
# 允许已建立和相关的连接流量：
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# 保存规则：
service iptables save
```
