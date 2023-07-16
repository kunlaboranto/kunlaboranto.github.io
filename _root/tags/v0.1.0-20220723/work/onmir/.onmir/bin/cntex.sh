#!/bin/sh

PID="DUAL"
test "x$1" != "x" && PID=$1

SQLCMD=is
test "x$2" != "x" && SQLCMD=$2

INTERVAL=1
INTERVAL=10
#INTERVAL=60
USLEEP_COST=50000           # gsql 접속후 cnt 수행시간

TS=0
TS_P=0
TS_D=0

CNT=0
CNT_P=0
CNT_D=0

ES=0
ES_P=0
ES_D=0

########################################
# FUNCTION
########################################

function doCnt
{
    ${SQLCMD} -silent << EOF
SELECT TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') ||' '||(SYSDATE-TRUNC(SYSDATE)) * 24 * 3600 ||' $TBL = '||SUM(PROCESS_ROW)||' '||SUM(EXECUTE_SUCCESS) 
  FROM V\$STATEMENT 
 WHERE SESSION_ID IN ( SELECT ID FROM V\$SESSION WHERE CLIENT_PID = $PID )
;

EOF
}


function doSID
{
    ${SQLCMD} -silent << EOF
set linesize 200;
SELECT SYSDATE||' |SID='||A.ID||
       ' |'||NVL(TO_CHAR(UX2DATE(A.IDLE_START_TIME),'HH24:MI:SS'),'HH:MI:SS')||
       ' |TX='||LPAD(A.TRANS_ID,10)||
       ' |ES='||LPAD(B.VALUE,8)
  FROM V\$SESSION A
       INNER JOIN V\$SESSTAT B ON B.SID = A.ID AND B.NAME = 'execute success count'
 WHERE A.CLIENT_PID = $PID ORDER BY A.TRANS_ID DESC
;

EOF
}


####################
# MAIN
####################


YYYY=`date "+%Y"`

doSID |grep ^${YYYY} |sed -e "s/ [ ]*$//g" |sed -e "s/^${YYYY}....//g"
echo ""

while :
do
    # 2018/11/3323 11:18:31.503713 COUNT = 100000 (0)
    RES=`doCnt |grep "^$YYYY" |sed -e "s;^..../../;;g" |sed -e "s/ [ ]*$//g"`
    #RES=[25 11:11:57 40317.835083  = 19278239 4819553]
    #echo "RES=[$RES]"; exit 0

    TM=`echo $RES |awk '{print $2}'`

    CNT_P=$CNT
    CNT=`echo $RES |sed -e "s/^.* = //" |awk '{print $1}'`
    CNT_D=`echo $CNT - $CNT_P |bc -l`

    ES_P=$ES
    ES=`echo $RES |sed -e "s/^.* = //" |awk '{print $2}'`
    ES_D=`echo $ES - $ES_P |bc -l`

    #test $CNT_D -gt 0 && TS_P=$TS
    TS_P=$TS
    TS=`echo $RES |awk '{print $3}'`
    TS_D=`echo "$TS - $TS_P" |bc`

    TPS=`echo "$CNT_D/$TS_D" |bc`
    TPSE=`echo "$ES_D/$TS_D" |bc`

    #echo "$RES [D,$CNT_D,TPS,$TPS] ES=[$ES,D,$ES_D]"
    echo "$TM CNT=[$CNT,D,$CNT_D,TPS,$TPS] ES=[$ES,D,$ES_D,TPS,$TPSE]"

    #sleep 1
    sleep $INTERVAL
    #usleep `echo "1000000 * 1 - $USLEEP_COST" |bc`
done

