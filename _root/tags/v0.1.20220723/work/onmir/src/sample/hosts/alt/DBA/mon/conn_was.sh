#!/bin/sh

INTERVAL=5

CUR_TIME=`date '+%Y%m%d'`
HOSTNAME=`/usr/bin/hostname`
DIR=$HOME/work/DBA/mon

function doIt
{
is -silent  <<EOF 
set colsize 100;
select rpad('WAS]',5)
       || rpad(to_char(sysdate,'DD HH:MI:SS'),14)
       || rpad(sum(was1),8)
       || rpad(sum(was2),8)
       || rpad(sum(was3),8)
       || rpad(sum(was4),8)
       || rpad(sum(was5),8)
       || rpad(sum(vip),8)
       || rpad(sum(batch),8)
       || rpad(sum(other),8)
     from (
     select decode(substr(comm_name,1,17), 'TCP 1.1.1.1:', count(*), 0)  WAS1
           ,decode(substr(comm_name,1,17), 'TCP 1.1.1.2:', count(*), 0)  WAS2
           ,decode(substr(comm_name,1,17), 'TCP 1.1.1.3:', count(*), 0)  VIP
           ,decode(substr(comm_name,1,17), 'TCP 1.1.1.4:', count(*), 0)  BATCH
           ,case2( substr(comm_name,1,17) != 'TCP 1.1.1.1:'
               and substr(comm_name,1,17) != 'TCP 1.1.1.2:'
               and substr(comm_name,1,17) != 'TCP 1.1.1.3:'
               and substr(comm_name,1,17) != 'TCP 1.1.1.4:'
               and substr(comm_name,1,17) != 'TCP 1.1.1.2:'
               and substr(comm_name,1,17) != 'TCP 1.1.1.2'
               and substr(comm_name,1,17) != 'TCP 1.1.1.3'
           ,count(*), 0)  OTHER
      from v\$session
      where 1 = 1
        and task_state = 'EXECUTING'
      group by substr(comm_name,1,17)
      order by 1
     )
     ;
EOF
}


LOOPCNT=0
while :
do
CUR_TIME=`date '+%Y%m%d'`

    LOOPCNT=`expr $LOOPCNT + 1`
    CHK=`expr $LOOPCNT % 10`

    if [ $CHK -eq 1 ] 
    then
        echo "WAS  SYSDATE       WAS(54) WAS(55) WAS(56) WAS(57)  WAS(62) EAI     BATCH   OTHER" >> $DIR/logs/$HOSTNAME"_WAS_"$CUR_TIME
    fi
doIt |grep "^WAS\] " >> $DIR/logs/$HOSTNAME"_WAS_"$CUR_TIME

    sleep $INTERVAL
done
