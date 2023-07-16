#!/bin/sh

TNAME="DUAL"
test "x$1" != "x" && TNAME=$1

SQLCMD=is
SQLCMD=is03
test "x$2" != "x" && SQLCMD=$2

USLEEP_COST=50000           # gsql 접속후 cnt 수행시간

TM=0
TM_P=0
TM_D=0

CNT=0
CNT_P=0
CNT_D=0

SIZE=0
SIZE_P=0
SIZE_D=0

########################################
# FUNCTION
########################################

function doUsr
{
    ${SQLCMD} -silent << EOF
alter session set explain plan = off;
set linesize 80;
set feedback off;

SELECT 'CUT='||USER_NAME
  FROM (SELECT U.USER_NAME
          FROM system_.sys_users_ U
             , system_.sys_tables_ T
         WHERE U.USER_ID = T.USER_ID
           AND U.USER_NAME LIKE '%OWN' 
       AND T.TABLE_NAME = UPPER('${TBL}')
         UNION ALL
        SELECT U.USER_NAME
          FROM system_.sys_users_ U
             , system_.sys_tables_ T
         WHERE U.USER_ID = T.USER_ID
           AND U.USER_NAME NOT LIKE '%OWN' 
       AND T.TABLE_NAME = UPPER('${TBL}')
       )
 WHERE ROWNUM = 1
;

EOF
}

function doCnt
{
    ${SQLCMD} -silent << EOF
select to_char(systimestamp,'YYYY/MM/DD HH24:MI:SS.FF3') ||' $TNAME = '||count(*) from $TNAME ;
EOF
}

function doSize
{
    ${SQLCMD} -silent << EOF
set linesize 120;
set colsize 40;

SELECT 'CUT='||ROUND(C.EXTENT_PAGE_COUNT * C.PAGE_SIZE * D.EXTENT_TOTAL_COUNT/1024/1024, 3) ALLOC
  FROM SYSTEM_.SYS_TABLES_ A
     , SYSTEM_.SYS_USERS_ B
     , V\$TABLESPACES C
     , V\$SEGMENT D
 WHERE 1=1
   --AND B.USER_NAME <> 'SYSTEM_' AND A.TBS_ID != 0 AND A.USER_ID != 1
   AND A.USER_ID = B.USER_ID 
   AND D.TABLE_OID = A.TABLE_OID 
   AND C.ID = A.TBS_ID
   AND B.USER_NAME = '${USR}'
   AND A.TABLE_NAME = '${TBL}'
   AND D.SEGMENT_TYPE = 'TABLE' 
;
EOF
}


####################
# MAIN
####################

chk=`echo $1 |grep "\." |wc -l`
if [ "x"$chk = "x0" ]
then
    TBL=$1
    USR=`doUsr ${TBL} |grep "^CUT=" |sed -e "s/^.*=//g"`
else
    TBL=`echo $1 |sed -e "s/\./ /g" |awk '{print $2}'`
    USR=`echo $1 |sed -e "s/\./ /g" |awk '{print $1}'`
fi

TBL=`echo ${TBL} |tr [a-z] [A-Z]`
USR=`echo ${USR} |tr [a-z] [A-Z]`

# Check Some Error ( ex. TABLE NOT_FOUND )
RES=`doCnt 2>&1`
chk=`echo $RES |grep -e "ERR-" -e "ORA-" |wc -l`
if [ "x"$chk != "x0" ]
then
    echo "$RES" 
    sleep 2
    exit 1
fi

#doSize ; exit

YYYY=`date "+%Y"`
while :
do
    SIZE_P=$SIZE
    SIZE=`doSize |grep "^CUT=" |sed -e "s/^.*=//g" |sed -e "s/ [ ]*$//g"`
    SIZE_D=`echo $SIZE - $SIZE_P |bc -l`

    # 2018/11/3323 11:18:31.503713 COUNT = 100000 (0)
    RES=`doCnt |grep "^$YYYY" |sed -e "s;^..../../;;g" |sed -e "s/ [ ]*$//g"`

    CNT_P=$CNT
    CNT=`echo $RES |sed -e "s/^.* //" `
    CNT_D=`echo $CNT - $CNT_P |bc -l`

    TM_P=$TM
    TM=`echo $RES |sed -e "s/^.*://" |sed -e "s/ .*$//g"`
    TM_D=`echo "$TM - $TM_P" |bc`
    TPS=`echo "$CNT_D/$TM_D" |bc`

    echo "$RES [D,$CNT_D,TPS,$TPS] SIZE[$SIZE,D,$SIZE_D]"

    sleep 1
    #usleep `echo "1000000 * 1 - $USLEEP_COST" |bc`
done

