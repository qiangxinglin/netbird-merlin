#!/bin/sh
# 该文件需保存为 UNIX 格式 (LF)

source /koolshare/scripts/base.sh
LOGFILE=/tmp/upload/netbird_log.txt 

start() {
    # 高级网络检测（持续检查直到能 ping 通外网）
    until ping -c1 8.8.8.8 >/dev/null; do
        sleep 2
    done
    # 检查是否已启用 NetBird
    if [ "$(dbus get netbird_enable)" == "1" ]; then
        /koolshare/scripts/netbird_service.sh start  
        nohup netbird up >> $LOGFILE 2>&1 & 
    fi
}

case "$1" in
start)
    start
    ;;
*)
    echo "Usage: $0 start"
    ;;
esac