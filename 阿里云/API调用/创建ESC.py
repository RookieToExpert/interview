# pip install aliyun-python-sdk-ecs
from aliyunsdkcore.client import AcsClient
client = AcsClient("<access_key_id>", "<access_secret>", "cn-hangzhou")
request = CreateInstanceRequest()
request.set_ImageId("centos_7")
response = client.do_action_with_exception(request)
