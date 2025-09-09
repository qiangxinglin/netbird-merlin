#!/bin/sh
source /koolshare/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
MODEL=
UI_TYPE=ASUSWRT
FW_TYPE_CODE=
FW_TYPE_NAME=
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
	local KS_TAG=$(nvram get extendno|grep koolshare)
	if [ -d "/koolshare" ];then
		if [ -n "${KS_TAG}" ];then
			FW_TYPE_CODE="2"
			FW_TYPE_NAME="koolshare官改固件"
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


get_ui_type(){
	# default value
	[ "${MODEL}" == "RT-AC86U" ] && local ROG_RTAC86U=0
	[ "${MODEL}" == "GT-AC2900" ] && local ROG_GTAC2900=1
	[ "${MODEL}" == "GT-AC5300" ] && local ROG_GTAC5300=1
	[ "${MODEL}" == "GT-AX11000" ] && local ROG_GTAX11000=1
	[ "${MODEL}" == "GT-AXE11000" ] && local ROG_GTAXE11000=1
	[ "${MODEL}" == "GT-AX6000" ] && local ROG_GTAX6000=1
	local KS_TAG=$(nvram get extendno|grep koolshare)
	local EXT_NU=$(nvram get extendno)
	local EXT_NU=$(echo ${EXT_NU%_*} | grep -Eo "^[0-9]{1,10}$")
	local BUILDNO=$(nvram get buildno)
	[ -z "${EXT_NU}" ] && EXT_NU="0"
	# RT-AC86U
	if [ -n "${KS_TAG}" -a "${MODEL}" == "RT-AC86U" -a "${EXT_NU}" -lt "81918" -a "${BUILDNO}" != "386" ];then
		# RT-AC86U的官改固件，在384_81918之前的固件都是ROG皮肤，384_81918及其以后的固件（包括386）为ASUSWRT皮肤
		ROG_RTAC86U=1
	fi
	# GT-AC2900
	if [ "${MODEL}" == "GT-AC2900" ] && [ "${FW_TYPE_CODE}" == "3" -o "${FW_TYPE_CODE}" == "4" ];then
		# GT-AC2900从386.1开始已经支持梅林固件，其UI是ASUSWRT
		ROG_GTAC2900=0
	fi
	# GT-AX11000
	if [ "${MODEL}" == "GT-AX11000" -o "${MODEL}" == "GT-AX11000_BO4" ] && [ "${FW_TYPE_CODE}" == "3" -o "${FW_TYPE_CODE}" == "4" ];then
		# GT-AX11000从386.2开始已经支持梅林固件，其UI是ASUSWRT
		ROG_GTAX11000=0
	fi
	# GT-AXE11000
	if [ "${MODEL}" == "GT-AXE11000" ] && [ "${FW_TYPE_CODE}" == "3" -o "${FW_TYPE_CODE}" == "4" ];then
		# GT-AXE11000从386.5开始已经支持梅林固件，其UI是ASUSWRT
		ROG_GTAXE11000=0
	fi
	# ROG UI
	if [ "${ROG_GTAC5300}" == "1" -o "${ROG_RTAC86U}" == "1" -o "${ROG_GTAC2900}" == "1" -o "${ROG_GTAX11000}" == "1" -o "${ROG_GTAXE11000}" == "1" -o "${ROG_GTAX6000}" == "1" ];then
		# GT-AC5300、RT-AC86U部分版本、GT-AC2900部分版本、GT-AX11000部分版本、GT-AXE11000官改版本， GT-AX6000 骚红皮肤
		UI_TYPE="ROG"
	fi
	# TUF UI
	if [ "${MODEL}" == "TUF-AX3000" ];then
		# 官改固件，橙色皮肤
		UI_TYPE="TUF"
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
			rm -rf /tmp/${module}* >/dev/null 2>&1
			exit 1
			;;
		0|*)
			rm -rf /tmp/${module}* >/dev/null 2>&1
			exit 0
			;;
	esac
}

install_ui(){
	# intall different UI
	get_ui_type
	if [ "${UI_TYPE}" == "ROG" ];then
		echo_date "安装ROG皮肤！"
		sed -i '/asuscss/d' /koolshare/webs/Module_${module}.asp >/dev/null 2>&1
	fi
	if [ "${UI_TYPE}" == "TUF" ];then
		echo_date "安装TUF皮肤！"
		sed -i '/asuscss/d' /koolshare/webs/Module_${module}.asp >/dev/null 2>&1
		sed -i 's/3e030d/3e2902/g;s/91071f/92650F/g;s/680516/D0982C/g;s/cf0a2c/c58813/g;s/700618/74500b/g;s/530412/92650F/g' /koolshare/webs/Module_${module}.asp >/dev/null 2>&1
	fi
	if [ "${UI_TYPE}" == "ASUSWRT" ];then
		echo_date "安装ASUSWRT皮肤！"
		sed -i '/rogcss/d' /koolshare/webs/Module_${module}.asp >/dev/null 2>&1
	fi
}


install_now(){
    local TITLE="netbird"
	local DESCR="基于wiregurad协议的零配置内网穿透安全组网工具"
	local PLVER=$(cat ${DIR}/version)

    # stop first
	local ENABLE=$(dbus get ${module}_enable)
	if [ "${ENABLE}" == "1" -a -f "/koolshare/scripts/${module}_config.sh" ];then
		echo_date "安装前先关闭${TITLE}插件，以保证更新成功！"
		sh /koolshare/scripts/${module}_config.sh stop >/dev/null 2>&1
	fi

    # remove some file first
    find /koolshare/init.d -name "*${module}*" | xargs rm -rf

    echo_date "安装插件相关文件..."
    # cp -rf /tmp/${module}/bin/* /koolshare/bin/
    cp -rf /tmp/${module}/res/* /koolshare/res/
    cp -rf /tmp/${module}/scripts/* /koolshare/scripts/
    cp -rf /tmp/${module}/webs/* /koolshare/webs/
	cp -rf /tmp/${module}/uninstall.sh /koolshare/scripts/uninstall_${module}.sh

    mkdir -p /koolshare/configs/netbird
    # 创建 /var/lib/netbird 软链接
	ln -sf /koolshare/configs/netbird /var/lib

    chmod 755 /koolshare/scripts/* >/dev/null 2>&1

    # make start up script link
	if [ ! -L "/koolshare/init.d/S97${module}.sh" -a -f "/koolshare/scripts/${module}_config.sh" ];then
		ln -sf /koolshare/scripts/${module}_config.sh /koolshare/init.d/S97${module}.sh
	fi

    # intall different UI
	install_ui

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

    # dbus value
	echo_date "设置插件默认参数..."
	dbus set ${module}_enable=0
	dbus set ${module}_version="${PLVER}"
	dbus set ${module}_management_url="https://api.netbird.io"
	dbus set ${module}_setup_key=""

	dbus set softcenter_module_${module}_version="${PLVER}"
	dbus set softcenter_module_${module}_install="1"
	dbus set softcenter_module_${module}_name="${module}"
	dbus set softcenter_module_${module}_title="${TITLE}"
	dbus set softcenter_module_${module}_description="${DESCR}"

    echo_date "${TITLE}插件安装完毕！"
	exit_install
}

install(){
	get_model
	get_fw_type
	platform_test
	install_now
}

install