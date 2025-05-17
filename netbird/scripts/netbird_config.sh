#!/bin/sh 
source /koolshare/scripts/base.sh
eval $(dbus export netbird) 
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
LOGFILE=/tmp/upload/netbird_log.txt 
LOGUPDATEFILE=/tmp/upload/netbird_update_log.txt 

case $1 in
start)
	if [ "${netbird_enable}" == "1" ];then
		echo start by wan-start >> ${LOGFILE}
	else
		logger "netbird插件未开启，跳过！"
	fi
	;;
esac

# submit by web
case $2 in
web_submit)
    echo "" > ${LOGFILE}
	echo_date "netbird merlin addon by zhaxg" >> ${LOGFILE}
    echo_date "netbird_enable:${netbird_enable}" >> ${LOGFILE}
	http_response "$1"
    if [ "${netbird_enable}" == "1" ];then
        echo_date "准备启动netbird" >> ${LOGFILE}
		/koolshare/scripts/netbird_service.sh start
        nohup netbird up >> $LOGFILE 2>&1 &
        echo_date "netbird up please wait ..." >> ${LOGFILE}
	else
        echo_date "准备关闭netbird" >> ${LOGFILE}
        netbird down
		/koolshare/scripts/netbird_service.sh stop
        sleep 3
	fi

    echo_date "操作完成" >> ${LOGFILE}
    echo "XU6J03M6" >> ${LOGFILE}
	;;
update)
    echo "" > ${LOGUPDATEFILE}
    http_response "update netbird please wait ..."

    echo_date "准备更新，检测必要条件" >> ${LOGUPDATEFILE}    
	GITAPI="https://api.github.com/repos/netbirdio/netbird/releases/latest"
	TAGNAME=$(curl -s ${GITAPI} | jq -r '.tag_name | sub("^v"; "")') 
 
    if [ "$TAGNAME" == "$netbird_version" ]; then
        echo_date "当前版本已是最新($netbird_version)，无需更新。" >> ${LOGUPDATEFILE} 
    else
        echo_date "当前版本：$netbird_version, 最新版本：$TAGNAME, 开始更新" >> ${LOGUPDATEFILE}
        dbus set netbird_version="$TAGNAME"

        PROXY="https://gh-proxy.com/"
        GITHUB="https://github.com/netbirdio/netbird/releases/download"
        DOWNLOAD_PATH="v${TAGNAME}/netbird_${TAGNAME}_linux_arm64.tar.gz"
        wget -O /tmp/netbird.tar.gz "${PROXY}${GITHUB}/${DOWNLOAD_PATH}" 2>&1 | tee ${LOGUPDATEFILE}
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
    #状态
    STATUS=$(netbird status)
    ENCODED_STATUS=$(echo "base64://"$(printf "%s" "$STATUS" | base64))
    
    ERRMSG="netbird-up无法重新建立连接，重试中，请稍等..."

    if printf '%s' "$STATUS" | grep "Signal: Connected"; then 
        netbird status --yaml > ${LOGFILE} #状态正常重置日志文件为详细状态信息
        echo "XU6J03M6" >> ${LOGFILE}
        http_response $ENCODED_STATUS
        return 0
    fi

    LOGIN_SUCCESS=$(grep -oE "Logging successfully" "$LOGFILE" | tail -n1) 
    if  [[ -n "$LOGIN_SUCCESS" ]]; then
        echo "XU6J03M6" > ${LOGFILE}
        nohup netbird up >> $LOGFILE 2>&1 &
        http_response "成功完成重新登录，正在启动连接，请稍等..."
        sleep 3
        return 0
    fi

    LOGIN_URL=$(grep -oE "https?://[^ ]*activate\?user_code=[^ ]+" "$LOGFILE" | tail -n1) 
    if  [[ -n "$LOGIN_URL" ]]; then
        MESSAGE="需要授权登录：<span class='auth-link'><a href='$LOGIN_URL' target='_blank'>$LOGIN_URL</a></span>"
        ENCODED_MESSAGE=$(echo "base64://"$(printf "%s" "$MESSAGE" | base64))
        http_response $ENCODED_MESSAGE
        return 0
    fi

    if printf '%s' "$STATUS" | grep "Daemon status: NeedsLogin"; then
        echo "XU6J03M6" > ${LOGFILE}
        nohup netbird login >> $LOGFILE 2>&1 &
        http_response "正在执行重新登录，请稍等..."
        sleep 3
        return 0
    fi

    http_response $ERRMSG
    ;;
esac