1. 写过什么shell脚本？

    **答案**:
    - 备份脚本：定时打包日志/数据库并上传远程。
    - 监控脚本：循环检测进程/端口是否存活，异常时报警。
    - 批处理脚本：批量创建用户、修改配置文件。
    - 部署脚本：一键拉取代码、编译、重启服务。
    比如举个例子：
    ```bash
    #!/bin/bash
    for host in $(cat hosts.txt); do
        scp app.tar.gz $host:/opt/
        ssh $host "cd /opt && tar -xf app.tar.gz && ./restart.sh"
    done
    ```
2. linux进程后面的Z代表什么？

    **答案**: 
    Z = **Zombie (僵尸进程)**。
    **含义**：子进程已退出，但父进程未调用 wait() 回收 → 占用进程号，不占 CPU。
    **解决方法**：
    - 确认父进程是否异常 → 重启父进程。
    - 杀父进程（init/systemd 接管，回收子进程）。
3. top命令关于cpu有哪些指标？

    **答案**:
    - **us**：用户态 CPU 使用率。
    - **sy**：内核态 CPU 使用率。
    - **id**：空闲 CPU。
    - **wa**：等待 I/O 的时间。
    - **ni**：低优先级进程的 CPU 占用。
    - **hi/si**：硬/软中断占用。
    - **st**：虚拟机被宿主机偷走的 CPU 时间。
4. 服务器cpu过高/服务器有故障，应该怎么排查？

    **答案**:
    - **确认现象**：top、uptime 看负载
    - **定位进程**：top 或 ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head。
    - **线程级分析**：top -H -p <pid>，再结合 pstack/strace 看调用栈。
    - **I/O / 网络**：iostat、vmstat、sar、ss -ant。
    - **系统日志**：dmesg、/var/log/messages。
    - **如果是突发流量**：看 Nginx/数据库慢查询/应用层逻辑。
5. 列举常用的linux命令？解释ps命令用于查看进程的常用选项。

    **答案**:
    常用命令：ls、cd、cat、grep、find、tar、scp、ssh、chmod、df、du、netstat/ss、systemctl 等。

    ps 常用选项：
    - **ps aux**：所有进程，用户、CPU、内存等。
    - **ps -ef**：完整格式，父子进程关系清晰。
    - **ps -u \<user>**：指定用户进程。
    - **ps -p \<pid>**：指定 PID。
    - **ps -o pid,ppid,cmd,%cpu,%mem**：自定义输出。
6. 如何使用命令查看开放的端口？

    **答案**:
    - **netstat -tulnp** （旧工具，需安装 net-tools）。
    - **ss -tulnp** （推荐，现代 Linux 默认有）。
    - **lsof -i :80** （查看具体哪个进程占用端口）。
7. 区分查看CPU使用率和CPU详细规格的命令。

    **答案**:
    - CPU 使用率（实时监控）：
        - top
        - mpstat -P ALL 1（需 sysstat 包）
        - sar -u 1 5
    - CPU 详细规格：
        - lscpu（架构、核心数、频率、缓存）。
        - cat /proc/cpuinfo（型号、厂商、flags）。
        - dmidecode -t processor（更详细，需 root）。
8. 解释grep命令用于文本搜索的高级选项。

    **答案**:
    - 正则匹配：
        - grep -E "error|fail" （扩展正则）。
        - grep -v pattern （排除）。
        - grep -o pattern （只显示匹配部分）。
    - 大小写：grep -i （忽略大小写）。
    - 显示行号：grep -n。
    - 统计出现次数：grep -c。
    - 递归搜索：grep -r "pattern" /var/log/。
    - 上下文：
        - grep -A3 "error"（匹配行+后3行）。
        - grep -B2 "error"（匹配行+前2行）。
        - grep -C2 "error"（前后各2行）。