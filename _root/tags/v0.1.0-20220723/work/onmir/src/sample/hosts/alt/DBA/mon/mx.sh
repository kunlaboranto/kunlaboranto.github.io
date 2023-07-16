#!/bin/sh

CUR_TIME=`date '+%Y%m%d'`
HOSTNAME=`/usr/bin/hostname`
DIR=$HOME/work/DBA/mon

function doIt
{

is -silent << EOF
set linesize 160;
set colsize 0;

select 'MX] '
       || to_char(sysdate,'DD HH:MI:SS')
       ||', '|| '[SERVICE THREAD]   '
       ||', RunT: '|| (select lpad(count(*),4) from v\$service_thread WHERE TYPE != 'IPC' AND state = 'EXECUTE')  
       ||', Thrd: '|| (select lpad(count(*),4) from v\$service_thread WHERE TYPE != 'IPC' )            
       ||', Task: '|| (select lpad(sum(TASK_COUNT),4) from v\$service_thread WHERE TYPE != 'IPC')            
       ||', Ready:' || (select lpad(sum(READY_TASK_COUNT),4) from v\$service_thread WHERE TYPE != 'IPC')            
  from dual
;

EOF

}


CUR_TIME=`date '+%Y%m%d'`
while :
do
CUR_TIME=`date '+%Y%m%d'`
    # doIt ; exit
    doIt |grep "^MX" |sed -e "s/ [ ]*$//g"  >> $DIR/logs/$HOSTNAME"_MX_"$CUR_TIME
    echo "--"  >> $DIR/logs/$HOSTNAME"_MX_"$CUR_TIME
    sleep 10
    #sleep 2
done
