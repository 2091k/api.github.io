#!/bin/sh

# 定义登录密码的 Base64 编码
encoded_password="YWRtaW4="  # admin 的 Base64 编码

# 登录后台并获取 Cookie
curl -s -X POST 'http://m.home/reqproc/proc_post' \
  -H 'User-Agent: Mozilla/5.0 (Linux; Android 14; Generic Android Build) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.6668.102 Mobile Safari/537.36' \
  -H 'Accept: application/json, text/javascript, */*; q=0.01' \
  -H 'Accept-Encoding: gzip, deflate' \
  -H 'X-Requested-With: XMLHttpRequest' \
  -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
  -H 'Origin: http://m.home' \
  -H 'Referer: http://m.home/index.html' \
  -H 'Accept-Language: zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7' \
  --data-urlencode 'goformId=LOGIN' \
  --data-urlencode "password=$encoded_password" > /dev/null

# 显示登录成功信息
echo "登录成功！按回车键继续进行 WiFi 配置..."
read -r

# 提示用户输入 WiFi SSID 和密码
echo "请输入 WiFi SSID 名称:"
read -r ssid
echo "请输入 WiFi 密码:"
read -r passphrase

# 将密码转换为 Base64 编码
encoded_passphrase=$(echo -n "$passphrase" | base64)

# 发送请求配置 WiFi
curl -X POST 'http://m.home/reqproc/proc_post' \
  -H 'User-Agent: Mozilla/5.0 (Linux; Android 14; Generic Android Build) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.6668.102 Mobile Safari/537.36' \
  -H 'Accept: application/json, text/plain, */*' \
  -H 'Accept-Encoding: gzip, deflate' \
  -H 'Content-Type: application/x-www-form-urlencoded;charset=UTF-8' \
  -H 'X-Requested-With: XMLHttpRequest' \
  -H 'Accept-Language: zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7' \
  --data-urlencode 'goformId=SET_WIFI_SSID1_SETTINGS' \
  --data-urlencode 'MAX_Access_num=10' \
  --data-urlencode 'security_mode=WPA2PSK' \
  --data-urlencode 'cipher=1' \
  --data-urlencode 'NoForwarding=0' \
  --data-urlencode 'security_shared_mode=0' \
  --data-urlencode "ssid=$ssid" \
  --data-urlencode "passphrase=$encoded_passphrase"

# 显示完成信息
echo "WiFi 已配置完成。"
