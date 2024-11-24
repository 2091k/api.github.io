#!/bin/bash

# 定义颜色变量
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m' # 无颜色

# 定义登录密码的 Base64 编码
encoded_password="YWRtaW4="  # admin 的 Base64 编码

# 登录后台并获取设备信息
curl -s -X POST 'http://m.home/reqproc/proc_post' \
  -H 'User-Agent: Mozilla/5.0 (Linux; Android 14; Generic Android Build) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.6668.102 Mobile Safari/537.36' \
  -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
  --data-urlencode 'goformId=LOGIN' \
  --data-urlencode "password=$encoded_password" > /dev/null

echo -e "${GREEN}登录成功！正在获取设备信息...${NC}"
echo

# 获取设备信息
response=$(curl -s 'http://m.home/reqproc/proc_get?multi_data=1&cmd=network_provider,lte_band,lte_rsrp,imei,ziccid,battery_pers,battery_charging,sta_count,wifi_cur_state,data_volume_limit_switch,cr_version,hw_version,lan_ipaddr,SSID1,realtime_time')

if [ -z "$response" ]; then
  echo -e "${RED}未能获取设备信息，请检查网络或设备状态。${NC}"
  exit 1
fi

# 提取字段并显示
network_provider=$(echo "$response" | grep -o '"network_provider":"[^"]*"' | cut -d':' -f2 | tr -d '"')
lte_rsrp=$(echo "$response" | grep -o '"lte_rsrp":"[^"]*"' | cut -d':' -f2 | tr -d '"')
lte_band=$(echo "$response" | grep -o '"lte_band":"[^"]*"' | cut -d':' -f2 | tr -d '"')

# 提取并显示局域网IP地址、SSID名称和开机时长
lan_ipaddr=$(echo "$response" | grep -o '"lan_ipaddr":"[^"]*"' | cut -d':' -f2 | tr -d '"')
SSID1=$(echo "$response" | grep -o '"SSID1":"[^"]*"' | cut -d':' -f2 | tr -d '"')
realtime_time=$(echo "$response" | grep -o '"realtime_time":"[^"]*"' | cut -d':' -f2 | tr -d '"')

# 转换开机时长（秒）为小时和分钟
hours=$((realtime_time / 3600))
minutes=$(((realtime_time % 3600) / 60))


case "$network_provider" in
  "China Unicom") network_provider="中国联通" ;;
  "China Telecom") network_provider="中国电信" ;;
  "China Mobile") network_provider="中国移动" ;;
  *) network_provider="未知运营商" ;;
esac

signal_strength="${lte_rsrp}dBm"
band="B${lte_band}"

# 显示运营商和信号强度信息
echo -e "${CYAN}运营商: ${YELLOW}${network_provider} ${signal_strength} ${band}${NC}"

echo -e "${CYAN}ICCID: ${YELLOW}$(echo "$response" | grep -o '"ziccid":"[^"]*"' | cut -d':' -f2 | tr -d '"')${NC}"
echo -e "${CYAN}IMEI: ${YELLOW}$(echo "$response" | grep -o '"imei":"[^"]*"' | cut -d':' -f2 | tr -d '"')${NC}"

# 处理电量和充电状态
battery_pers=$(echo "$response" | grep -o '"battery_pers":"[^"]*"' | cut -d':' -f2 | tr -d '"')
battery_charging=$(echo "$response" | grep -o '"battery_charging":"[^"]*"' | cut -d':' -f2 | tr -d '"')

if [ "$battery_charging" = "1" ]; then
  battery_status="充电中"
else
  battery_status=""
fi

case "$battery_pers" in
  "1") battery_pers="25%" ;;
  "2") battery_pers="50%" ;;
  "3") battery_pers="75%" ;;
  "4") battery_pers="100%" ;;
  *) battery_pers="未知" ;;
esac

# 显示电量信息
if [ -n "$battery_status" ]; then
  echo -e "${CYAN}电量: ${YELLOW}${battery_status}  ${battery_pers}${NC}"
else
  echo -e "${CYAN}电量: ${YELLOW}${battery_pers}${NC}"
fi

sta_count=$(echo "$response" | grep -o '"sta_count":"[^"]*"' | cut -d':' -f2 | tr -d '"')
echo -e "${CYAN}已连接设备: ${YELLOW}${sta_count} 台${NC}"

wifi_cur_state=$(echo "$response" | grep -o '"wifi_cur_state":"[^"]*"' | cut -d':' -f2 | tr -d '"')
if [ "$wifi_cur_state" = "1" ]; then
  echo -e "${CYAN}网络开关: ${GREEN}开启${NC}"
else
  echo -e "${CYAN}网络开关: ${RED}关闭${NC}"
fi

echo -e "${CYAN}局域网IP地址: ${YELLOW}$lan_ipaddr${NC}"
echo -e "${CYAN}SSID名称: ${YELLOW}$SSID1${NC}"
echo -e "${CYAN}开机时长: ${YELLOW}${hours}小时 ${minutes}分钟${NC}"

cr_version=$(echo "$response" | grep -o '"cr_version":"[^"]*"' | cut -d':' -f2 | tr -d '"')
hw_version=$(echo "$response" | grep -o '"hw_version":"[^"]*"' | cut -d':' -f2 | tr -d '"')

# 显示前15位软件版本
cr_version_short=${cr_version:0:15}  # 截取前15位

echo -e "${CYAN}软硬件版本: ${YELLOW}${cr_version_short} / ${hw_version}${NC}"

# 提供选择菜单
echo -e "\n${GREEN}请选择操作:${NC}"
echo -e "1. 修改 WiFi 名称和密码"
echo -e "2. 重启设备"
echo -e "3. 退出\n"

# 读取用户输入的选项
echo -n "请输入选项 [1/2/3]: "
read choice

case "$choice" in
  2)
    # 重启设备
    echo -e "${CYAN}正在重启设备...${NC}"
    response=$(curl -s -X POST 'http://m.home/reqproc/proc_post' \
      -H 'User-Agent: Mozilla/5.0 (Linux; Android 14; MEIZU 20 Pro Build/UKQ1.230917.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/129.0.6668.102 Mobile Safari/537.36 Html5Plus/1.0' \
      -H 'Accept: application/json, text/plain, */*' \
      -H 'Accept-Encoding: gzip, deflate' \
      -H 'Content-Type: application/x-www-form-urlencoded;charset=UTF-8' \
      -H 'X-Requested-With: plus.fuckzxw' \
      -H 'Accept-Language: zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7' \
      --data-urlencode 'goformId=REBOOT_DEVICE')

    # 检查重启是否成功
    if echo "$response" | grep -q "success"; then
      echo -e "${GREEN}设备已成功重启！${NC}"
    else
      echo -e "${RED}重启中...${NC}"
    fi
    ;;
  1)
    # 修改 WiFi 名称和密码
    echo -e "\n${CYAN}请输入 WiFi SSID 名称:${NC}"
    read -r ssid
    echo -e "${CYAN}请输入 WiFi 密码:${NC}"
    read -r passphrase
    encoded_passphrase=$(echo -n "$passphrase" | base64)

    curl -s -X POST 'http://m.home/reqproc/proc_post' \
      -H 'User-Agent: Mozilla/5.0' \
      -H 'Content-Type: application/x-www-form-urlencoded;charset=UTF-8' \
      --data-urlencode 'goformId=SET_WIFI_SSID1_SETTINGS' \
      --data-urlencode 'MAX_Access_num=10' \
      --data-urlencode 'security_mode=WPA2PSK' \
      --data-urlencode 'cipher=1' \
      --data-urlencode 'NoForwarding=0' \
      --data-urlencode 'security_shared_mode=0' \
      --data-urlencode "ssid=$ssid" \
      --data-urlencode "passphrase=$encoded_passphrase"

    echo -e "${GREEN}WiFi 名称和密码已修改完成！${NC}"
    ;;
  3)
    echo -e "${YELLOW}已退出程序。${NC}"
    ;;
  *)
    echo -e "${RED}无效选项，请重试！${NC}"
    ;;
esac
