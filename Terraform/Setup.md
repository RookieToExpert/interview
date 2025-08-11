## 基础配置
1. 安装AzureCLI和TerraformCLI
2. 在Visual studio中安装Terraform的插件
3. 运行以下命令：
  1. `terraform init`
  配置terraform的基础配置
4. 安装一个service principle:
   ```azcli
   D:\Terraform>az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/268fc89b-21a4-4b13-9bc1-b9967924248f
   Creating 'Contributor' role assignment under scope '/subscriptions/268fc89b-21a4-4b13-9bc1-b9967924248f'
   The output includes credentials that you must protect. Be sure that you do not include these credentials in your code or check the credentials into your source control. For more information, see https://aka.ms/azadsp-cli
   {
   "appId": "21feec74-d0b4-4e32-8e22-62689c906cd7",
   "displayName": "azure-cli-2025-08-11-07-34-41",
   "password": "SGY8Q~t9QhBTrhdQolswYOy9uLI6j1KWLiodGam7",
   "tenant": "60956884-10ad-40fa-863d-4f32c1e3a37a"
   }
  ```
  配置环境变量：
    ```cmd
    setx ARM_TENANT_ID 60956884-10ad-40fa-863d-4f32c1e3a37a
    setx ARM_CLIENT_SECRET SGY8Q~t9QhBTrhdQolswYOy9uLI6j1KWLiodGam7
    setx ARM_SUBSCRIPTION_ID 268fc89b-21a4-4b13-9bc1-b9967924248f
    setx ARM_TENANT_ID 60956884-10ad-40fa-863d-4f32c1e3a37a
    ```
5. 运行:```terraform apply```:
  会自动创建一个resource group：

  <img width="885" height="567" alt="image" src="https://github.com/user-attachments/assets/8a42b707-1409-4583-846b-571b1ad5c33d" />

6. 创建好了rg后，可以通过运行```terraform show```，或者查看terraform.tfstate的文件查看到目前通过terraform创建的资源。
