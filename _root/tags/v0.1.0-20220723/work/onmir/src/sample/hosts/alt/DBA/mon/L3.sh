#!/bin/sh

INTERVAL=5

CUR_TIME=`date '+%Y%m%d'`
HOSTNAME=`/usr/bin/hostname`
DIR=$HOME/work/DBA/mon

LOOPCNT=0

function doIt
{
is -silent << EOF

set linesize 180;
set colsize 15;

select distinct 
       'CUT=' AS CUT
     , a.TRANS_ID
     , b.id AS TRANS_SS
     , a.WAIT_FOR_TRANS_ID
     , c.id WAIT_FOR_TRANS_SS
     , tb.table_name
     --, sysdate AS DT
     , ux2date(c.IDLE_START_TIME) as W4IDLE
  from v\$lock_wait a
       left outer join v\$session b
               on b.trans_id = a.TRANS_ID
       left outer join v\$session c
               on c.trans_id = a.WAIT_FOR_TRANS_ID
       left outer join v\$lock lc
               on lc.trans_id = a.trans_id
              AND lc.table_oid <> -1
       left outer join system_.sys_tables_ tb
               on tb.table_oid = lc.table_oid
;

EOF
}

while :
do
CUR_TIME=`date '+%Y%m%d'`
    DT=`date "+%d %H:%M:%S"`

    echo "    TX_ID               TX_SS     WAIT_4_TX         WAIT_4_SID    TABLE                    ($DT) " >>$DIR/logs/$HOSTNAME"_LWAIT_"$CUR_TIME
    echo "--------------------------------------------------------------------------------------------------------" >>$DIR/logs/$HOSTNAME"_LWAIT_"$CUR_TIME
    doIt |grep "^CUT=" |sed -e "s/ [ ]*$//g" |sed -e "s/CUT=//g" >>$DIR/logs/$HOSTNAME"_LWAIT_"$CUR_TIME
    echo "" >>$DIR/logs/$HOSTNAME"_LWAIT_"$CUR_TIME
 
    sleep 10 
done
