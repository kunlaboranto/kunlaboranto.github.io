#!/bin/sh

function run
{
    OSPID=$1

    sqlplus -S "/as sysdba" << EOF
SELECT 
       'ALTER SYSTEM KILL SESSION '''||A.SID||','||A.SERIAL#||''' /* '||B.SPID||', '||A.USERNAME||'@'||A.MACHINE||' */ ;'
  FROM V\$SESSION A, V\$PROCESS B
 WHERE A.PADDR = B.ADDR
   AND A.USERNAME IN ( 'MON_IMSI' )
   AND B.SPID IN ( ${OSPID} )
;
EOF
}

####################
# MAIN
####################

for OSPID in `netstat -nap 2>&1 |grep ":1521.*CLOSE_WAIT" |sed -e "s;/.*$;;g" |sed -e "s/^.* //g" `
do
    run $OSPID |grep "^ALTER "
    # ps -p $OSPID -opcpu,cmd
done

exit 0

# [NOTE]
# 1) Tibero
#    그러나, 통상(?)적인 테스트로는 client PID를 Kill 한 경우 감지되어 세션이 정리가 됨, 때문에 만들어 두지 않음
# 2) AIX
#    netstat 에 '-p' 옵션 없음, lsof 를 조합으로 사용하면 가능하나, 현재 실행권한 없음

SELECT 'ALTER SYSTEM KILL SESSION '''||A.SID||','||A.SERIAL#||''' /* '||A.CLIENT_PID||', '||A.USERNAME||'@'||A.MACHINE||' */ ;'
     , a.*
  FROM V$SESSION A
 where 1=1
   and A.CLIENT_PID = 10342
   and A.STATUS = 'RUNNING'
   and A.SCHEMANAME not like 'US_%'
;
