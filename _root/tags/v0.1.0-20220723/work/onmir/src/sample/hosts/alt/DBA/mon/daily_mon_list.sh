#!/bin/sh

export PATH=.:$PATH
export ISQL_CONNECTION=IPC

echo "[ Monitoring Shell Status ]"
ps -ef |grep "^$LOGNAME " |grep -v grep |grep -v vi |grep -e "L3.sh" -e "mx.sh" -e "buff.sh" -e "conn_was.sh"

echo "Do you want Restart monitoring Shell? (Y/N) \c"
read YN

if [ "x"$YN != "xY" -a "x"$YN != "xy" ]
then
    echo "OK... Canceled, (YN=$YN)"
    exit
fi

echo "OK... Continue ..(YN=$YN) "

ps -ef |grep "^$LOGNAME " |grep -v grep |grep -v vi |grep -e "L3.sh" -e "mx.sh" -e "buff.sh" -e "conn_was.sh" |awk '{print "kill "$2}' > _kill_mon_list.sh

sh -v _kill_mon_list.sh
sleep 1
sh -v _kill_mon_list.sh
sleep 1

CNT=`ps -ef |grep "^$LOGNAME " |grep -v grep |grep -v vi |grep -e "L3.sh" -e "mx.sh" -e "buff.sh" -e "conn_was.sh" |wc -l`

if [ $CNT -ne 0 ]
then
    echo "[ERROR] kill failed, Check and Retry !"
    exit
fi

echo "[Restarting .. ]"; sleep 2

DT=`date "+%b%d_%H%M%S"`

nohup sh L3.sh  &
nohup sh mx.sh &
nohup sh buff.sh &
nohup sh conn_was.sh &

#### nohup vmstat 5 1111111111 >> logs/vmstat.log_$DT &
#### nohup sh gp.sh &

sleep 1

echo "[ Monitoring Shell Status ($DT) ]"
ps -ef |grep "^$LOGNAME " |grep -v grep |grep -v vi |grep -e "L3.sh" -e "mx.sh" -e "vmstat 5" -e "buff.sh" -e "gp.sh" -e "conn_was.sh"

