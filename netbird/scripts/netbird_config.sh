#!/bin/sh

source /koolshare/scripts/base.sh
eval $(dbus export netbird)
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
LOGFILE=/tmp/upload/netbird_log.txt
LOGSVCFILE=/tmp/upload/netbird_service_log.txt
LOGUPDATEFILE=/tmp/upload/netbird_update_log.txt

add_iptables_rule() {
    # $1: 操作类型，"add" 表示添加，"del" 表示删除
    echo_date "获取 netbird IPv4 地址..." >> ${LOGFILE}
    NETBIRD_IPV4=""
    COUNT=0
    while [ -z "$NETBIRD_IPV4" ] && [ $COUNT -lt 30 ]; do
        NETBIRD_IPV4=$(netbird status --ipv4 2>/dev/null)
        if [ -n "$NETBIRD_IPV4" ]; then
            break
        fi
        sleep 1
        COUNT=$((COUNT+1))
    done
    if [ -n "$NETBIRD_IPV4" ]; then
        LAN_IP=$(nvram get lan_ipaddr)
        iptables -t nat -A PREROUTING -d $NETBIRD_IPV4/32 -j DNAT --to-destination $LAN_IP -m comment --comment "netbird_rule"
        echo_date "添加 iptables DNAT: $NETBIRD_IPV4" >> ${LOGFILE}
    else
        echo_date "netbird IPv4 获取超时, 未进行 DNAT 设置" >> ${LOGFILE}
    fi
}

delete_iptables_rule() {
    iptables -t nat -D PREROUTING $(iptables -t nat -L --line-numbers | grep "netbird_rule" | awk '{print $1}') >/dev/null 2>&1
    echo_date "删除 netbird DNAT" >> ${LOGFILE}
}

close_in_five() {
	echo_date "插件将在5秒后自动关闭！！"
	local i=5
	while [ $i -ge 0 ]; do
		sleep 1
		echo_date $i
		let i--
	done
	dbus set netbird_enable="0"
	echo_date "插件已关闭！！"
	exit
}

start_netbird() {
    export NB_SETUP_KEY=${netbird_setup_key}
    export NB_MANAGEMENT_URL=${netbird_management_url}
    export NB_LOG_LEVEL=error
    export NB_DISABLE_PROFILES=true
    export NB_DISABLE_DNS=true

    echo_date "启动 netbird service" >> ${LOGFILE}
    start-stop-daemon -S -b -q -m -p /var/run/netbird.pid -x /koolshare/bin/netbird -- service run --log-file ${LOGSVCFILE}

    local exist_pid
    local i=10
    until [ -n "${exist_pid}" ]; do
        exist_pid=$(pidof "netbird")
        i=$((i-1))
        if [ $i -eq 0 ]; then
            echo_date "netbird service 启动失败" >> ${LOGFILE}
            close_in_five
        fi
        usleep 250000
    done
    echo_date "netbird service 启动成功, pid: ${exist_pid}" >> ${LOGFILE}

    netbird up >> ${LOGFILE}
    sleep 3

    add_iptables_rule
}

stop_netbird() {
    echo_date "停止 netbird" >> ${LOGFILE}
    netbird down
    killall -9 netbird 2>/dev/null
    delete_iptables_rule
}



case $1 in
start)
	if [ "${netbird_enable}" == "1" ];then
		start_netbird
		logger "[软件中心]: 启动netbird！"
	fi
	;;
restart)
    stop_netbird
    start_netbird
    ;;
stop)
    stop_netbird
	;;
esac

# submit by web
case $2 in
web_submit)
    echo "" > ${LOGFILE}
	http_response "$1"
    stop_netbird
    if [ "${netbird_enable}" == "1" ];then
        start_netbird
	fi

    echo_date "操作完成" >> ${LOGFILE}
    echo "XU6J03M6" >> ${LOGFILE}
	;;
update)
    echo "" > ${LOGUPDATEFILE}
    http_response "update netbird please wait ..."

    latest_version_url="https://api.github.com/repos/netbirdio/netbird/releases/latest"
    latest_version_file="/tmp/netbird_latest_version.json"
    echo_date "准备更新，检测最新版本：$latest_version_url" >> ${LOGUPDATEFILE}

    wget "$latest_version_url" -O "$latest_version_file"
    tag_name=$(cat $latest_version_file | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    download_url=$(cat $latest_version_file | grep '"browser_download_url":' | grep 'linux_arm64.tar.gz' | sed -E 's/.*"([^"]+)".*/\1/')

    if [[ "$tag_name" == "$netbird_version" ]]; then
        echo_date "当前版本已是最新($netbird_version)，无需更新。" >> ${LOGUPDATEFILE}
    else
        echo_date "当前版本：$netbird_version, 最新版本：$tag_name, 开始更新" >> ${LOGUPDATEFILE}
        dbus set netbird_version="$tag_name"

        wget -O /tmp/netbird.tar.gz "https://ghfast.top/${download_url}" 2>&1 | tee ${LOGUPDATEFILE}
        tar -xzf /tmp/netbird.tar.gz -C /koolshare/bin/
        chmod 755 /koolshare/bin/netbird

        echo_date "准备重新启动netbird" >> ${LOGUPDATEFILE}
		/koolshare/scripts/netbird_service.sh restart
        nohup netbird up >> $LOGFILE 2>&1 &
    fi

    echo_date "操作完成" >> ${LOGUPDATEFILE}
    echo "XU6J03M6" >> ${LOGUPDATEFILE}

    ;;
status)
    STATUS=$(netbird status)
    ENCODED_STATUS=$(echo "base64://"$(printf "%s" "$STATUS" | base64))
    http_response $ENCODED_STATUS
    ;;
esac