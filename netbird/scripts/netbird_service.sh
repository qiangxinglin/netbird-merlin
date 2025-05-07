#!/bin/sh

alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
LOGFILE=/tmp/upload/netbird_log.txt
LOGSVCFILE=/tmp/upload/netbird_service_log.txt

PROCS=netbird
ARGS="service run --log-file ${LOGSVCFILE}"
DESC="Netbird Service"  

#nohup netbird service run > /tmp/upload/netbird.log 2>&1 &
#killall -9 netbird 2>/dev/null

# 使用nohup启动并重定向输出
start() {
    local exist_pid=$(pidof "$PROCS")
    if [ -n "$exist_pid" ]; then
        echo_date "$DESC already running with PID $exist_pid" >> ${LOGFILE}
        return 0
    fi
    echo "" > ${LOGSVCFILE}
    nohup /koolshare/bin/$PROCS $ARGS >> ${LOGFILE} 2>&1 &
    echo_date "$DESC started with PID $!" >> ${LOGFILE}
}

# 停止时根据PID终止
stop() { 
    killall -9 $PROCS 2>/dev/null
    echo_date "$DESC stopped" >> ${LOGFILE}
}

# 使用start-stop-daemon管理进程
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        sleep 2
        start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac

exit 0