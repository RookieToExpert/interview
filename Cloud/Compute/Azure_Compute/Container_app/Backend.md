[返回compute](https://github.com/RookieToExpert/interview/blob/main/Cloud/Compute/compute.md)
## Lab: Build a To-do application
#### Build the backend:
## Coding:
1. Create an ASP.NET Web API framework:

    ![alt text](image.png)

    ![alt text](image-1.png)

    ![alt text](image-2.png)

    ![alt text](image-3.png)

2. Create and publish the docker image of the frontend app to docker hub:

    ![alt text](image-38.png)

    publish this image to docker hub:

    ![alt text](image-41.png)

3. Add coding to the frontend and backend to ensure they can communicate:
    在前端中创建一个client与后端api(todo class)交互：

    ![alt text](image-4.png)

    ![alt text](image-5.png)

    与后端交互的代码：

    ![alt text](image-6.png)

3. Create the backend container app and use your own image:

    ![alt text](image-7.png)

    仅限container apps通信，没有public access(因为是后端api):

    ![alt text](image-8.png)

    所以直接用broswer访问是禁止的：


    ![alt text](image-9.png)
