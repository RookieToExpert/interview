## DevOps篇：
1. DevOps代码扫描是什么？

    **答案**：
    DevOps 里的 代码扫描 指的是在持续集成/持续交付（CI/CD）流程中，对应用源代码或构建产物进行自动化的安全和质量检查，**发现安全漏洞，检查代码质量，符合规范**。

    - 开发阶段用**IDE 内置扫描插件**，实时提示代码问题
    - 提交阶段用**Git Hooks / GitHub Actions / Azure DevOps Pipeline**自动触发扫描
    - 构建阶段对**代码、依赖、Docker 镜像**进行安全扫描
    - 部署阶段运行 **DAST** 或基础设施扫描，验证上线环境。

2. DevOps中get和management有什么区别？

    **答案**：
    - Get表示获取某些状态/信息，例如 CI/CD pipeline 在执行前去 “get” 最新的代码、依赖或扫描结果。
    - Management表示对整个应用生命周期进行管理比如代码扫描，构建/部署流程，云资源/集群的管理

## Terraform篇：
1. 如何用Terraform删除资源？

    **答案**：
    - 删除单个资源，在 .tf 配置文件中 删除或注释掉该资源的定义，然后执行plan和apply。或使用**terraform destroy -target销毁特定资源**。

    - 删除整个环境，直接**terraform destroy**。

    - 只想从state移除，不想terraform管理某个资源，可以运行**terraform state rm azurerm_resource_group.example**。  