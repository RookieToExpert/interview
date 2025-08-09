## 创建新的rg，storage account

<img width="1453" height="541" alt="image" src="https://github.com/user-attachments/assets/099597ab-3bbc-4be7-9478-554ebbf06d76" />

## 创建新的container app environment，新添加了dapr的设置，用storage account去存state，重新build和push镜像

<img width="1154" height="502" alt="image" src="https://github.com/user-attachments/assets/7e8f86cd-1e10-4fa4-b876-4593f609dea7" />

yaml文件：

<img width="804" height="341" alt="image" src="https://github.com/user-attachments/assets/dd43bbb1-1567-42fa-a6c2-7ef9e3378cc1" />


## 重新创建一遍frontend和backend container app，并且去enable-dapr

<img width="670" height="766" alt="image" src="https://github.com/user-attachments/assets/776bd0bf-5213-4e0d-891f-27fcaff66b46" />

## 修改前端代码，把原本call backend api的代码改成用dapr的状态管理和服务调用去call后端服务：

<img width="1380" height="261" alt="image" src="https://github.com/user-attachments/assets/f6621eea-d0c5-4d17-ae34-eff847782100" />

<img width="1155" height="455" alt="image" src="https://github.com/user-attachments/assets/4a84817c-0a3c-4600-8b5e-1ce150671939" />

## 再去看frontend，可以看到现在会记数了，也就是状态，存到的是storage account里面

<img width="1295" height="564" alt="image" src="https://github.com/user-attachments/assets/9ff8de3c-2ba1-45a3-8962-0d8ed99e3c05" />

<img width="1887" height="597" alt="image" src="https://github.com/user-attachments/assets/28b0fcdf-8c16-474e-bc02-9fc1b4b78671" />

