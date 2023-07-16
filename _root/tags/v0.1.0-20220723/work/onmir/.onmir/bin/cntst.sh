#!/bin/sh

SID=$1
#test "x$1" != "x" && PID=$1

SQLCMD=is
SQLCMD=.is2
test "x$2" != "x" && SQLCMD=$2

INTERVAL=1
#INTERVAL=10
USLEEP_COST=50000           # gsql 접속후 cnt 수행시간

CR=0
CR_P=0
CR_D=0

PR=0
PR_P=0
PR_D=0

TX=0
TX_P=0
TX_D=0

RX=0
RX_P=0
RX_D=0

########################################
# FUNCTION
########################################

function doIt
{
    ${SQLCMD} -silent << EOF
SELECT TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS.FF3')
    || ' cr= '||( SELECT SUM(VALUE) FROM V\$SESSTAT WHERE SID IN ( $SID ) AND NAME LIKE 'data page gets' )
    || ' pr= '||( SELECT SUM(VALUE) FROM V\$SESSTAT WHERE SID IN ( $SID ) AND NAME LIKE 'data page read' )
    || ' TX= '||( SELECT ROUND(SUM(VALUE)/8/1024,0) FROM V\$SESSTAT WHERE SID IN ( $SID ) AND NAME LIKE 'byte sent via inet' )
    || ' RX= '||( SELECT ROUND(SUM(VALUE)/8/1024,0) FROM V\$SESSTAT WHERE SID IN ( $SID ) AND NAME LIKE 'byte received via inet' )
  FROM DUAL
;

EOF
}

####################
# MAIN
####################

YYYY=`date "+%Y"`

#doIt ; exit 0
#echo "Usage: cntst.sh <session_id> \n"
#echo ">>\n"

while :
do
    # 2018/11/3323 11:18:31.503713 COUNT = 100000 (0)
    RES=`doIt |grep "^$YYYY" |sed -e "s;^..../../;;g" |sed -e "s/ [ ]*$//g"`
    #RES=[25 11:11:57 40317.835083  = 19278239 4819553]
    #echo "RES=[$RES]"; exit 0

    TM=`echo $RES |awk '{print $2}'`

    CR_P=$CR
    CR=`echo $RES |sed -e "s/^.*cr= //" |awk '{print $1}'`
    CR_D=`echo $CR - $CR_P |bc -l`

    PR_P=$PR
    PR=`echo $RES |sed -e "s/^.*pr= //" |awk '{print $1}'`
    PR_D=`echo $PR - $PR_P |bc -l`

    TX_P=$TX
    TX=`echo $RES |sed -e "s/^.*TX= //" |awk '{print $1}'`
    TX_D=`echo $TX - $TX_P |bc -l`

    RX_P=$RX
    RX=`echo $RES |sed -e "s/^.*RX= //" |awk '{print $1}'`
    RX_D=`echo $RX - $RX_P |bc -l`

    #echo "$TM CR=[$CR,D,$CR_D] PR=[$PR,D,$PR_D] TX=[$TX,D,$TX_D] "
    printf "%s CR=[%s,D,%6s] PR=[%s,D,%6s] TX=[%s,D,%6s] RX=[%s,D,%6s] \n" $TM $CR $CR_D $PR $PR_D $TX $TX_D $RX $RX_D

    #sleep 1
    sleep $INTERVAL
    #usleep `echo "1000000 * 1 - $USLEEP_COST" |bc`

#exit 1
done



exit 0
SYSDATE              NAME                                  VALUE
-------------------- ------------------------------------- -------------------
2020/06/16 17:03:30  data page read                                    7373231
2020/06/16 17:03:30  data page gets                                   86488457
2020/06/16 17:03:30  data page fix                                           0
2020/06/16 17:03:30  session commit                                          1
2020/06/16 17:03:30  read socket count                                  741162
2020/06/16 17:03:30  write socket count                                 741162
2020/06/16 17:03:30  byte received via inet                           21494594
2020/06/16 17:03:30  byte sent via inet                            22896457537
2020/06/16 17:03:30  memory table cursor index scan count                    4
2020/06/16 17:03:30  disk table cursor index scan count                      1
2020/06/16 17:03:30  lock acquired count                                    25
2020/06/16 17:03:30  lock released count                                     3
2020/06/16 17:03:30  [event_us] db file single page read            5600159302
2020/06/16 17:03:30  [event_us] latch free: drdb LRU list             11185044

