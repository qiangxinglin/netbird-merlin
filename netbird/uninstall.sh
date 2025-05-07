#!/bin/sh
# 卸载脚本路径: /koolshare/scripts/uninstall_netbird.sh

source /koolshare/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'


# 停止服务
/koolshare/scripts/netbird.sh stop >/dev/null 2>&1

echo_date "删除netbird插件相关文件！"

# 删除所有相关文件
rm -rf /koolshare/scripts/netbird* >/dev/null 2>&1         # 通配符删除所有netbird脚本
rm -rf /koolshare/webs/Module_netbird.asp >/dev/null 2>&1
rm -rf /koolshare/res/icon-netbird.png >/dev/null 2>&1
rm -rf /koolshare/bin/netbird >/dev/null 2>&1 

# 清除 JFFS 中的临时文件（如有）
rm -rf /tmp/netbird* >/dev/null 2>&1

# 移除自启动项目
cru d netbird_auto >/dev/null 2>&1
rm -rf /koolshare/init.d/*NetBird.sh >/dev/null 2>&1  # 匹配大写文件名

# 删除数据库配置
dbus remove netbird_enable
dbus remove netbird_management_url
dbus remove netbird_setup_key
dbus remove softcenter_module_netbird_install
dbus remove softcenter_module_netbird_version

# 强制刷新软件中心界面（仅 Merlin 固件需要）
if [ -n "$(pidof skipd)" ]; then
    service restart_skipd >/dev/null 2>&1
    service restart_webui >/dev/null 2>&1
fi

echo_date "netbird插件卸载成功！"
echo_date "-------------------------------------------"
echo_date "卸载保留了netbird配置文件夹: /etc/netbird/config.json"
echo_date "如果你希望重装netbird插件后，完全重新配置netbird"
echo_date "请重装插件前手动删除文件夹/etc/netbird/config.json"
echo_date "-------------------------------------------"
exit 0