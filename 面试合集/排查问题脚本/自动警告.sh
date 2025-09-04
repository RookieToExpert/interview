# 示例：发送钉钉告警
webhook="https://oapi.dingtalk.com/robot/send?access_token=xxx"
message="服务器CPU超过90%！"
curl -s $webhook -H "Content-Type: application/json" -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"$message\"}}"
