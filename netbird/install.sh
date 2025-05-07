#!/bin/sh
source /koolshare/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
MODEL="BE-3600"
FW_TYPE_CODE="4"
FW_TYPE_NAME="koolshare梅林改版固件"
DIR=$(cd $(dirname $0); pwd)
module=${DIR##*/}

get_model(){
	local ODMPID=$(nvram get odmpid)
	local PRODUCTID=$(nvram get productid)
	if [ -n "${ODMPID}" ];then
		MODEL="${ODMPID}"
	else
		MODEL="${PRODUCTID}"
	fi
}

get_fw_type() {
	local KS_TAG=$(nvram get extendno|grep -Eo "kool.+")
	if [ -d "/koolshare" ];then
		if [ -n "${KS_TAG}" ];then
			FW_TYPE_CODE="2"
			FW_TYPE_NAME="${KS_TAG}官改固件"
		else
			FW_TYPE_CODE="4"
			FW_TYPE_NAME="koolshare梅林改版固件"
		fi
	else
		if [ "$(uname -o|grep Merlin)" ];then
			FW_TYPE_CODE="3"
			FW_TYPE_NAME="梅林原版固件"
		else
			FW_TYPE_CODE="1"
			FW_TYPE_NAME="华硕官方固件"
		fi
	fi
}

platform_test(){
	local LINUX_VER=$(uname -r|awk -F"." '{print $1$2}')
	if [ -d "/koolshare" -a -f "/usr/bin/skipd" -a "${LINUX_VER}" -ge "41" ];then
		echo_date 机型："${MODEL} ${FW_TYPE_NAME} 符合安装要求，开始安装插件！"
	else
		exit_install 1
	fi
}

exit_install(){
	local state=$1
	case $state in
		1)
			echo_date "本插件适用于【koolshare 梅林改/官改 hnd/axhnd/axhnd.675x】固件平台！"
			echo_date "你的固件平台不能安装！！!"
			echo_date "本插件支持机型/平台：https://github.com/koolshare/rogsoft#rogsoft"
			echo_date "退出安装！"
			# rm -rf /tmp/netbird* >/dev/null 2>&1
			exit 1
			;;
		0|*)
			# rm -rf /tmp/netbird* >/dev/null 2>&1
			exit 0
			;;
	esac
}

install_now(){
    local TITLE="netbird"
	local DESCR="基于wiregurad协议的零配置内网穿透安全组网工具！"
	local PLVER=$(cat ${DIR}/version)
 
	echo_date "安装前停止运行中的旧版本插件..."	
	if [ "$(dbus get netbird_enable)" == "1" ] && [ -f "/koolshare/scripts/netbird.sh" ]; then
		echo_date "检测到 NetBird 正在运行，执行安装前关闭..."
		sh /koolshare/scripts/netbird.sh stop 
		sleep 2 
	fi
 
	echo_date "安装前彻底清理旧版本残留文件..."	
	rm -rf /koolshare/bin/netbird* >/dev/null 2>&1              # 删除二进制文件
	rm -rf /koolshare/res/icon-netbird.png >/dev/null 2>&1      # 删除图标
	rm -rf /koolshare/scripts/netbird_* >/dev/null 2>&1         # 删除所有 netbird 开头脚本
	rm -rf /koolshare/scripts/uninstall_netbird.sh >/dev/null 2>&1 # 删除卸载脚本
	rm -rf /koolshare/webs/Module_netbird.asp >/dev/null 2>&1        # 删除所有 ASP 页面
	find /koolshare/init.d -name "*netbird*" -o -name "*NetBird*" | xargs rm -rf  # 删除大小写变种的 init.d 脚本
 
    echo_date "复制文件..."	
    cp -rf /tmp/netbird/init.d/* /koolshare/init.d/
    cp -rf /tmp/netbird/scripts/* /koolshare/scripts/
	cp -rf /tmp/netbird/uninstall.sh /koolshare/scripts/uninstall_netbird.sh
    cp -rf /tmp/netbird/webs/* /koolshare/webs/
    cp -rf /tmp/netbird/res/* /koolshare/res/
  
	echo_date "设置权限..."	
    chmod 755 /koolshare/scripts/*netbird*.sh 
    chmod 755 /koolshare/init.d/*NetBird.sh
	chmod 644 /koolshare/webs/Module_netbird.asp

    # 下载二进制文件
    ARCH=$(uname -m)
    case "$ARCH" in
        armv7l)  BIN_ARCH="armv7" ;;
        aarch64) BIN_ARCH="arm64" ;;
        x86_64)  BIN_ARCH="amd64" ;;
        *)       echo "不支持的架构"; exit 1 ;;
    esac

	echo_date "开始下载NetBird二进制文件..."
	#https://gh-proxy.com/https://github.com/netbirdio/netbird/releases/download/v0.43.2/netbird_0.43.2_linux_arm64.tar.gz
	PROXY="https://gh-proxy.com/"
	GITHUB="https://github.com/netbirdio/netbird/releases/download"
	GITAPI="https://api.github.com/repos/netbirdio/netbird/releases/latest"
	TAGNAME=$(curl -s ${GITAPI} | jq -r '.tag_name | sub("^v"; "")')
	DOWNLOAD_PATH="v${TAGNAME}/netbird_${TAGNAME}_linux_${BIN_ARCH}.tar.gz"
	wget -O /tmp/netbird.tar.gz "${PROXY}${GITHUB}/${DOWNLOAD_PATH}" 
    tar -xzf /tmp/netbird.tar.gz -C /koolshare/bin/
    chmod 755 /koolshare/bin/netbird

    # 创建卸载数据库 
	echo_date "设置插件默认参数..."
	dbus set netbird_enable=0 
	dbus set netbird_version="${PLVER}"
	dbus set netbird_management_url="https://api.netbird.io"
	dbus set netbird_setup_key=""
	dbus set softcenter_module_netbird_version="${PLVER}"
	dbus set softcenter_module_netbird_install="1"
	dbus set softcenter_module_netbird_name="netbird"
	dbus set softcenter_module_netbird_title="${TITLE}"
	dbus set softcenter_module_netbird_description="${DESCR}"

    echo_date "${TITLE}插件安装完毕！"
	exit_install 0
}

install(){
	get_model
	get_fw_type
	platform_test
	install_now
}

install