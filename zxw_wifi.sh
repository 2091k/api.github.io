#!/bin/sh

# 定义登录密码的 Base64 编码
encoded_password="YWRtaW4="  # admin 的 Base64 编码

# 登录后台并获取设备信息
curl -s -X POST 'http://m.home/reqproc/proc_post' \
  -H 'User-Agent: Mozilla/5.0 (Linux; Android 14; Generic Android Build) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.6668.102 Mobile Safari/537.36' \
  -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
  --data-urlencode 'goformId=LOGIN' \
  --data-urlencode "password=$encoded_password" > /dev/null

# 显示登录成功信息
echo "登录成功！正在获取设备信息..."
echo

# 访问设备信息接口
response=$(curl -s 'http://m.home/reqproc/proc_get?multi_data=1&cmd=network_provider,_RESIDE_BAND,lte_band,remo_band,imei,ziccid,lte_rsrp,signalbar,battery_pers,battery_charging,sta_count,loginfo,cr_version,hw_version,wifi_cur_state&_=1732420087954')

# 判断返回数据是否为空
if [ -z "$response" ]; then
  echo "未能获取设备信息，请检查网络或设备状态。"
  exit 1
fi

# 显示设备信息
echo "设备信息如下："

# 解析和格式化字段
# 运营商
network_provider=$(echo "$response" | grep -o '"network_provider":"[^"]*"' | cut -d':' -f2 | tr -d '"')
case "$network_provider" in
  "China Unicom") network_provider="中国联通" ;;
  "China Telecom") network_provider="中国电信" ;;
  "China Mobile") network_provider="中国移动" ;;
  *) network_provider="未知" ;;
esac
echo "运营商: $network_provider"

# ICCID
ziccid=$(echo "$response" | grep -o '"ziccid":"[^"]*"' | cut -d':' -f2 | tr -d '"')
echo "ICCID: $ziccid"

# IMEI
imei=$(echo "$response" | grep -o '"imei":"[^"]*"' | cut -d':' -f2 | tr -d '"')
echo "IMEI: $imei"

# 电量
battery_pers=$(echo "$response" | grep -o '"battery_pers":"[^"]*"' | cut -d':' -f2 | tr -d '"')
case "$battery_pers" in
  "1") battery_pers="25%" ;;
  "2") battery_pers="50%" ;;
  "3") battery_pers="75%" ;;
  "4") battery_pers="100%" ;;
  *) battery_pers="未知" ;;
esac
echo "电量: $battery_pers"

# 已连接设备数
sta_count=$(echo "$response" | grep -o '"sta_count":"[^"]*"' | cut -d':' -f2 | tr -d '"')
echo "已连接设备: $sta_count 台"

# 网络开关
wifi_cur_state=$(echo "$response" | grep -o '"wifi_cur_state":"[^"]*"' | cut -d':' -f2 | tr -d '"')
if [ "$wifi_cur_state" = "1" ]; then
  echo "网络开关: 开启"
else
  echo "网络开关: 关闭"
fi

# 软硬件版本
cr_version=$(echo "$response" | grep -o '"cr_version":"[^"]*"' | cut -d':' -f2 | tr -d '"')
hw_version=$(echo "$response" | grep -o '"hw_version":"[^"]*"' | cut -d':' -f2 | tr -d '"')
echo "软硬件版本: $cr_version / $hw_version"

# 等待用户继续操作
echo
echo "按回车键设置WiFi信息..."
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