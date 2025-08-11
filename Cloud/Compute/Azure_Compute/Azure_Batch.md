[返回compute](https://github.com/RookieToExpert/interview/blob/main/Cloud/Compute/compute.md)
## Azure Batch
**Azure Batch 是一个面向高性能并行计算的托管服务，能在海量 VM 上批量执行脚本、作业或模拟任务，自动扩缩、调度和重试**

![alt text](image.png)

## Lab

1. Create a Batch account along assosicate it with a storage account:

    ![alt text](image-3.png)

    ![alt text](image-4.png)

    Overview:

    ![alt text](image-5.png)

2. Create a pool in batch account:

    ![alt text](image-6.png)

    Operating system:

    ![alt text](image-8.png)

    ![alt text](image-9.png)

    Scaleing option:

    ![alt text](image-10.png)

3. Create a job:

    ![alt text](image-11.png)

4. Create two similar tasks inside the job:

    ![alt text](image-12.png)
    
    ![alt text](image-13.png)

> 可以用azure CLI同时提交上千个task：

<img width="974" height="414" alt="image" src="https://github.com/user-attachments/assets/b1e291e4-59a0-47c5-9ef6-f2adb50c0271" />

