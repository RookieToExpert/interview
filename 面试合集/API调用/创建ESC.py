# 导入阿里云 SDK 核心类和 ECS 相关的请求类
from aliyunsdkcore.client import AcsClient
from aliyunsdkecs.request.v20140526 import CreateInstanceRequest

# 1. 初始化与认证
# 使用你的阿里云 Access Key ID、Access Key Secret 和区域信息初始化 AcsClient
client = AcsClient(
    "your-access-key-id",        # 替换为你的 Access Key ID
    "your-access-key-secret",    # 替换为你的 Access Key Secret
    "cn-hangzhou"                # 替换为你想要创建 VM 的区域
)

# 批量创建虚拟机数量
vm_count = 3

for i in range(vm_count):
    # 2. 构建创建虚拟机的请求
    request = CreateInstanceRequest.CreateInstanceRequest()
    
    # 设置虚拟机镜像 ID（必须根据实际情况替换为有效的镜像 ID）
    request.set_ImageId("ubuntu_18_04_64_20G_alibase_20200930.vhd")
    
    # 设置实例规格，比如 ecs.t5-lc2m1.nano（根据需求和区域提供的规格进行替换）
    request.set_InstanceType("ecs.t5-lc2m1.nano")
    
    # 设置虚拟机所属的 VPC、子网等信息（如果需要，可以设置更多参数）
    # request.set_VpcId("vpc-xxxxxxxx")
    # request.set_VSwitchId("vsw-xxxxxxxx")
    
    # 你还可以设置其他参数，比如安全组、系统盘大小、实例名称等
    request.set_InstanceName(f"batch-vm-{i+1}")
    
    # 3. 调用 API 发起请求
    try:
        response = client.do_action_with_exception(request)
        print(f"虚拟机 {i+1} 创建响应：", response)
    except Exception as e:
        print(f"虚拟机 {i+1} 创建失败：", e)
