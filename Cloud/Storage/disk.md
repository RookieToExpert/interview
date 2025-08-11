## Azure disk types:

![alt text](./image/image.png)

## encryption types for managed disks:

数据传输过程：

![alt text](./image/image-1.png)

**Azure Disk Encryption**

在VM中就通过比如bitlocker/dm-crypt将本地数据加密

![alt text](./image/image-4.png)

**Server-Side Encryption**

host将数据传送到Azure storage blob层时加密

![alt text](./image/image-2.png)

**Encrpytion at host**

在host层就已经加密，传给blob的数据是已经加密过的

![alt text](./image/image-3.png)