#!/bin/sh

source /koolshare/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'


sh /koolshare/scripts/netbird_config.sh stop >/dev/null 2>&1

rm -f /koolshare/bin/netbird
find /koolshare/init.d -name "*netbird*" | xargs rm -rf
rm -rf /koolshare/res/icon-netbird.png
rm -rf /koolshare/scripts/netbird_*.sh
rm -rf /koolshare/webs/Module_netbird.asp
rm -f /koolshare/scripts/uninstall_netbird.sh
rm -f /var/lib/netbird
# rm -rf /koolshare/configs/netbird

# 清除临时文件（如有）
rm -rf /tmp/netbird*

values=$(dbus list netbird | cut -d "=" -f 1)
for value in $values; do
    dbus remove $value
done

echo_date "netbird插件卸载成功！"
echo_date "-------------------------------------------"
echo_date "卸载保留了netbird配置文件夹: /koolshare/configs/netbird/*"
echo_date "如果你希望重装netbird插件后，完全重新配置netbird"
echo_date "请重装插件前手动删除文件夹 /koolshare/configs/netbird/*"
echo_date "-------------------------------------------"
