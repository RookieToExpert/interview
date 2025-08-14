## 将tfstate传至云端
1. 去terraform cloud注册账号，并创建好workspace和organization

   <img width="1920" height="429" alt="image" src="https://github.com/user-attachments/assets/ecffd52a-3af6-4b62-9d41-06c1088d8544" />

2. 在本地terraform创建一个backend.tf文件：

   <img width="763" height="356" alt="image" src="https://github.com/user-attachments/assets/f02fed0e-eb44-4721-af76-9b2b09af666a" />

   或者用新写法：

   ```hcl
   terraform {
  cloud {
    organization = "RayCompany"
    workspaces { name = "prd" }
    }
   }

   ```

3. 跑```terraform init -reconfigure -migrate-state```去push到云端，此时本地的tfstate会变成空白

4. 用以下代码可以验证：
```terraform
terraform workspace show   # 应是 prd
terraform state list       # 能列出资源表示已连上远端 state

```