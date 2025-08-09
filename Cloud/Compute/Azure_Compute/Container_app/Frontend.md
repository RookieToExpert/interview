## Lab: Build a To-do application
#### Build the frontend
1. Create a container app called to-do frontend:

    Create an **enviornment** first:

    ![alt text](image-28.png)

    Environment be like:

    ![alt text](image-27.png)

    Linked to a **log analytics workspace**:

    ![alt text](image-29.png)

    Select use you own network if need to engage with on-premise users or apps:

    ![alt text](image-30.png)

    ![alt text](image-31.png)

2. Select the image:
    Use one of the quickstart image to test first:

    ![alt text](image-32.png)
    
    Overview page:

    ![alt text](image-33.png)

3. Test if the container apps work by browsing its URL:

    ![alt text](image-34.png)

#### Write the customized frontend code:
1. Create a visual studio project:

    ![alt text](image-35.png)

    ![alt text](image-36.png)

2. Replace the home index file to my to-do list code and 写一些coding部分:

    ![alt text](image-37.png)


3. Create and publish the docker image of the frontend app to docker hub:

    ![alt text](image-38.png)

    Create a docker file:

    ![alt text](image-39.png)

    Create image of this docker file:

    ![alt text](image-40.png)

    publish this image to docker hub:

    ![alt text](image-41.png)

4. Recreate the container app and use your own image:

    ![alt text](image-42.png)

    ![alt text](image-43.png)