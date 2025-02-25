Sure thing. Let me tell you about a project where I helped a customer migrate their entire on-prem data center—everything from **SQL Server clusters** and **web apps** to an **on-prem Kubernetes** setup and **Active Directory**—over to Azure. It was a pretty big deal, 
so I’ll walk you through the major steps.
## Evaluation
First off, we checked out their existing environment. They had a bunch of Windows and Linux servers, and some of the Linux boxes were on older distributions where Azure Migrate’s Mobility Agent wasn’t fully supported. We collaborated with the customer’s 
team to schedule a kernel upgrade. We usually tested this in a staging environment to ensure no dependencies would break, and we planned the downtime carefully to keep critical services running.

After we got a good picture of their setup, we are using Azure Migrate’s discovery tools to figure out which **applications and databases depended on each other**.We also worked closely with their **architecture team** to decide which VM sizes should use based on 
indicator like memory-to-vCPU ratio, disk I/O, throughput for each server role—like web servers, SQL servers, Exchange servers, and backend servers—so we could balance performance and cost. 

*For example, we typically recommended:
**Web servers with moderate traffic**: Standard D2s_v3 or B-series VMs, offering a balanced CPU/memory ratio.
**SQL servers that are memory-intensive**: E-series or M-series VMs, providing higher memory-to-vCPU ratios ideal for large in-memory databases.
**Exchange servers**: Carefully sized to handle spikes in email concurrency and I/O demands.
**Backend servers**: Often benefit from the flexibility of the D-series for a mix of compute and memory.*

In terms of storage, we evaluated Standard HDD, Premium SSD, or Ultra SSD based on each application’s IOPS and throughput needs, making sure each workload had the right disk tier to match its performance requirements. From there, we set up a network 
in Azure, making sure the IP address ranges didn’t overlap with on-prem. We created separate subnets for web, data, and management layers just like their on-premise network environment, and we also integrated the customer’s local DNS zones into Azure DNS, ensuring 
that internal name resolution worked seamlessly in both environments. We also used Network Security Groups and Azure Firewall to make sure everything stayed locked down.
## Install mobility agent
Then came the installation of the Mobility Agent on all the servers—both Windows and Linux. In some Linux servers, we found that the official installer would sometimes fail because of SELinux restrictions or certain file system attributes—like the /var partition 
being mounted with noexec—which prevented the agent from running scripts or installing properly. We then created a script that quickly updated all the affected servers to remount /var without the noexec flag, we actually used a simple shell script combined with an 
inventory list of all the servers. The script connected over SSH to each server automatically and updated the mount options, so it was effectively one command that iterated through every machine. That saved us a ton of time compared to doing it manually.
## Replication
When it was time to actually replication, the customer was using Azure Private Link for the replication traffic, which meant all data flowed through private endpoints. Initially, some of their local DNS servers couldn’t resolve the private endpoint correctly, causing 
replication failures on a few machines. We caught this by running checks like tnc (Test-NetConnection), telnet, or ping to see if we could reach the endpoint. Then we dive deeper with Wireshark,  We filtered for DNS traffic (port 53) and saw that requests for the 
private endpoint domain were returning NXDOMAIN or failing to respond.  Once we updated the DNS records for the private endpoints for the DNS server, replication started working for most servers.

However, a handful of servers still couldn’t connect securely. We also filtered traffic on TCP port 443 to examine the TLS handshake. We saw those servers only offered outdated ciphers (like RC4) and didn’t support TLS 1.2 cipher suites Azure expects. 
Once we enabled or installed these cipher suites on the older servers, the TLS handshake succeeded. 

Meanwhile, since it will swamp their network bandwidth if all the servers are replicating at the same tiime. We split up the SQL databases into different replication groups based on their importance—critical workloads got replicated first, 
and the less urgent ones came later.

## Test Migration
Once replication was going smoothly, we did a test migration. We fired up everything in Azure—the web apps, SQL clusters, and the AKS environment—and tested it all. That meant checking DNS resolution, hitting endpoints with Postman to test various HTTP methods 
(e.g., GET, POST) and confirm the correct status codes (like 200, 404, 500) as well as verify the JSON or HTML payloads. This let us compare responses against the on-prem environment to ensure functionality and data consistency, and making sure the SQL queries 
in Azure returned the same results as on-prem. For example, we ran queries like "SELECT COUNT(*)" on critical tables to compare row counts, "SELECT TOP 10 * FROM Orders ORDER BY OrderDate DESC" to check recent transactions, and executed stored procedures that 
the application relied on to confirm they produced identical results in both environments. By comparing these outputs, we verified data integrity, row consistency, and overall application functionality post-migration. We also ran a small stress test on the new 
AKS cluster with tools like Apache JMeter or Locust, ensuring CPU, memory, and network usage stayed within acceptable limits under load.

We did run into a hiccup where some domain-joined servers lost their trust relationship with AD after we failed them over, but we got that squared away by working with the AD team, rejoining them to the domain, and updating the DNS records. Another issue was 
network latency in certain regions, which we tracked down using packet captures and log analytics, and then fixed by adjusting some routing.
## Final Migration
Once we were sure everything looked good, we scheduled the final cutover to avoid the customer’s peak business hours. Honestly, at that point, it was pretty smooth sailing. We hit our RTO of 2 hours, so no major drama.

