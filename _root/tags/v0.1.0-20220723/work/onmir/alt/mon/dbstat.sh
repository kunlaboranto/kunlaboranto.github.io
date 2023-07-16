#!/bin/sh

test "x"$DBMS = "x" && DBMS=alt
test "x"$3   != "x" && DBMS=$3

# [2018/05/09 10:54:37]
# DTIME=" 10:"
DTIME="^.201....... 10:"
test "x"$2 != "x" && DTIME=$2

FN=$1

function f_epoch_time
{
    echo "\
#!/usr/bin/perl

use strict;
use warnings;
use Time::Local;

my \$args = shift || die;
my (\$date, \$time) = split(' ', \$args);
my (\$year, \$month, \$day) = split('/', \$date);
my (\$hour, \$minute, \$second) = split(':', \$time);

\$year = (\$year<100 ? (\$year<70 ? 2000+\$year : 1900+\$year) : \$year);
print timelocal(\$second,\$minute,\$hour,\$day,\$month-1,\$year);  
" \
> /tmp/$LOGNAME/_10_epoch_time.pl

perl /tmp/$LOGNAME/_10_epoch_time.pl "$*"
}

# date -d"1970-01-01 09:00:00" +%s
function doDTM
{
    SDT=`f_epoch_time "$1"`
    EDT=`f_epoch_time "$2"`
    #echo `echo "$EDT - $SDT" |bc`
    echo "CUT="`echo "$EDT - $SDT" |bc`
}

function doDTM2
{
    .is2s <<EOF
SELECT 'CUT='||ROUND( ( TO_DATE('$2','YYYY/MM/DD HH24:MI:SS') - TO_DATE('$1','YYYY/MM/DD HH24:MI:SS') ) * 24 * 3600 , 0 ) FROM DUAL;
EOF
}

_STM=""

# [2018/11/12 10:58:40] SEQNUM= [2]  NAME= [data page read]  VALUE= [6635680646]  
function doStat
{
    FSTR="$1"
    OUT="${LOGD}/_10_out.${FSTR}"

    grep "${DTIME}.*${FSTR}" $FN > "${OUT}"

    if [ "x${_STM}" != "x" ]
    then
        STM=$_STM
        ETM=$_ETM
        DTM=$_DTM 
    else
        STM=`cat "${OUT}" |head -1 |sed -e "s/\[//g" |sed -e "s/\]//g" |awk '{print $1" "$2}'`
        ETM=`cat "${OUT}" |tail -1 |sed -e "s/\[//g" |sed -e "s/\]//g" |awk '{print $1" "$2}'`
        DTM=`doDTM "$STM" "$ETM" |grep ^CUT= |sed -e "s/^CUT=//g" |sed -e "s/ //g" `

        _STM=$STM
        _ETM=$ETM
        _DTM=$DTM 
    fi

    SVAL=`cat "${OUT}" |head -1 |sed -e "s/.*\[//g" |sed -e "s/\]//g" |sed -e "s/ //g"`
    EVAL=`cat "${OUT}" |tail -1 |sed -e "s/.*\[//g" |sed -e "s/\]//g" |sed -e "s/ //g"`
    DVAL=`echo $EVAL - $SVAL |bc -l`
    #AVAL=`echo "scale=2; ( $EVAL - $SVAL ) / $DTM" |bc -l`
    AVAL=`echo "( $EVAL - $SVAL ) / $DTM" |bc`

    #RES=",$STM,$DTM,$DVAL,$AVAL,$FSTR"
    RES=`echo "" |awk -v V_STM="$STM" \
                      -v V_DTM="$DTM" \
                      -v V_DVAL="$DVAL" \
                      -v V_AVAL="$AVAL" \
                      -v V_FSTR="$FSTR" \
                      '{ printf("   | %s| %s| %18s| %10s| %48s|\n", V_STM,V_DTM,V_DVAL,V_AVAL,V_FSTR) }'`

    if [ "x$2" = "x1" ]
    then
        echo "$RES"
    fi
}

function doAVG
{
    FSTR="$1"
    OUT="${LOGD}/out.${FSTR}"

    if [ "x$FSTR" = "xCPU usage" ]
    then
        # [2018/11/21 10:00:11] ALTIBASE PID=[12938],  CPU usage=[4658.88]%,   VSZ=[331766624]kbytes
        grep "${DTIME}.*${FSTR}" $FN |sed -e "s/\%.*$//g" |sed -e "s/.*\[//g" |sed -e "s/\]//g" > "${OUT}"
    else
        # [2018/03/14 10:01:30] TOTAL= [420]  RUN_TD= [300]  TASK_CNT= [4002]  READY_TASK= [75]  STMT= [5732]
        # [2018/03/14 10:01:30] SYSDATE= [2018/03/14 10:01:29]  IS_LOCK= [1187]  IX_LOCK= [2557]  X_LOCK= [1]  
        grep "${DTIME}.*${FSTR}" $FN |sed -e "s/^.*${FSTR}//g" |sed -e "s/\].*$//g" |sed -e "s/^.*\[//g" > "${OUT}"
        #echo "[ERROR] Unkwon 'FSTR' Option ($FSTR)" ; exit 1
    fi

    R_AVG=`cat "${OUT}" |awk '{ sum += $1; num++ } END { printf "%.2f", sum/num }' |sed -e "s/\.00//g"`
    R_MAX=`cat "${OUT}" |awk '{ max = max > $1 ? max : $1 } END { printf "%.2f", max }' |sed -e "s/\.00//g"`
    R_MIN=`cat "${OUT}" |awk 'BEGIN { min=2147483648 } { min = min < $1 ? min : $1 } END { printf "%.2f", min }' |sed -e "s/\.00//g"`

    RES=`echo "" |awk -v R_STM="$_STM" \
                      -v R_DTM="$_DTM" \
                      -v R_AVG="$R_AVG" \
                      -v R_MAX="$R_MAX" \
                      -v R_MIN="$R_MIN" \
                      -v R_FSTR="$FSTR" \
                      '{ printf("   | %s| %s| %6s| %6s| %6s| %20s|\n", R_STM,R_DTM,R_AVG,R_MAX,R_MIN, R_FSTR) }'`

    if [ "x$2" = "x1" ]
    then
        echo "$RES"
    fi
}

####################
# MAIN
####################

echo ">> $FN START"

if [ ! -f $FN ]
then
    echo "Input File ($FN) NOt Found."
    exit 1
else
    chk=`cat $FN |grep "${DTIME}" |wc -l`
    if [ "x$chk" = "x0" ]
    then
        echo ">> $FN END (wc=$chk)"
        exit 2
    fi
fi

STM=""
ETM=""

mkdir -p /tmp/$LOGNAME
LOGD=/tmp/$LOGNAME
ECHO=0

# grep -e " 10:.*CPU" -e " 10:.*data page read" -e " 10:.*elapsed time: get page(disk)" /tmp/kk  |grep -v "\[[0-9][0-9][0-9]\."

doStat "execute success count" $ECHO
EXEC_CNT=$DVAL

doStat "elapsed time: query execute" $ECHO
EXEC_US=$DVAL

doStat "data page read" $ECHO
PREAD_CNT=$DVAL

doStat "elapsed time: get page(disk)" $ECHO
PREAD_US=$DVAL

# doStat "xx" $ECHO
# xx=$DVAL

doStat "write redo log bytes" $ECHO
V_RedoWB=$DVAL

doStat "write redo log count" $ECHO
V_RedoWC=$DVAL

doStat "session commit" $ECHO
V_COMMIT=$DVAL

if [ "x$ECHO" = "x1" ]
then
    # UNDO
    doStat "elapsed time: write undo record in DML(disk)"
    doStat "elapsed time: allocate undopage in dml(disk)"
    doStat "undo page read"
    doStat "undo page create"

    # REDO
    doStat "write redo log count"
    doStat "write redo log bytes"

    echo ">> |                TIME| 기간|                VAL|        AVG|                                             NAME|"
fi

doAVG "CPU usage" $ECHO
V_CPU_AVG=$R_AVG
V_CPU_MAX=$R_MAX
V_CPU_MIN=$R_MIN

doAVG "RUN_TD= " $ECHO
V_MX_RUNT_AVG=$R_AVG
V_MX_RUNT_MAX=$R_MAX
V_MX_RUNT_MIN=$R_MIN

doAVG "READY_TASK= " $ECHO
V_MX_READY_AVG=$R_AVG
V_MX_READY_MAX=$R_MAX
V_MX_READY_MIN=$R_MIN

doAVG "IX_LOCK= " $ECHO
V_IX_LOCK_AVG=$R_AVG
V_IX_LOCK_MAX=$R_MAX
V_IX_LOCK_MIN=$R_MIN

doAVG "IS_LOCK= " $ECHO
V_IS_LOCK_AVG=$R_AVG
V_IS_LOCK_MAX=$R_MAX
V_IS_LOCK_MIN=$R_MIN


####################
# FINAL
####################

echo ""
#      >> | 2018/03/14 10:01:32| 3424|  24.72|    84675|   198.66|      972|      25428|   3513|    14109|        7|  5964.67|  6588.10|  5616.00| 1.70| 7595| 651| get page(disk)|
#echo ">> |                TIME| 기간|  RunTA| ReadyA|  RunTM| ReadyM|PRead_sec| PRead MB| us/PRead|   #PREAD/s| #SQL/s| usec/sql| read/sql|     %CPU|%CPU(MAX)|%CPU(MIN)| RedoMB|  #RedoWC| Commit|           DESC|"
 echo ">> |                TIME| 기간|  RunTA| ReadyA|  RunTM| ReadyM| IS_LOCKA| IX_LOCKA| IS_LOCKM| IX_LOCKM|PRead_sec| PRead MB| us/PRead|   #PREAD/s| #SQL/s| usec/sql| read/sql|     %CPU|%CPU(MAX)|%CPU(MIN)| RedoMB|  #RedoWC| Commit|           DESC|"

             #-v V_PREAD_COST=`echo "scale=2; $PREAD_US / 1000000 / $_DTM " |bc -l` \

echo "" |awk -v V_STM="$_STM" \
             -v V_DTM="$_DTM" \
             -v V_MX_READY_AVG="$V_MX_READY_AVG" \
             -v V_MX_RUNT_AVG="$V_MX_RUNT_AVG" \
             -v V_MX_READY_MAX="$V_MX_READY_MAX" \
             -v V_MX_RUNT_MAX="$V_MX_RUNT_MAX" \
             -v V_IS_LOCK_AVG="$V_IS_LOCK_AVG" \
             -v V_IX_LOCK_AVG="$V_IX_LOCK_AVG" \
             -v V_IS_LOCK_MAX="$V_IS_LOCK_MAX" \
             -v V_IX_LOCK_MAX="$V_IX_LOCK_MAX" \
             -v V_PREAD_SEC=`echo $PREAD_US / 1000000 |bc` \
             -v V_PREAD_MB_SEC=`echo "scale=2; ( $PREAD_CNT * 8 * 1024 ) / $_DTM / ( 1024 * 1024 ) " |bc -l` \
             -v V_AVG_PREAD_US=`echo "$PREAD_US / $PREAD_CNT" |bc` \
             -v V_PREAD_CNT_SEC=`echo " $PREAD_CNT / $_DTM " |bc` \
             -v V_EXEC_CNT_SEC=`echo " $EXEC_CNT / $_DTM " |bc` \
             -v V_AGV_EXEC_US=`echo "$EXEC_US / $EXEC_CNT" |bc` \
             -v V_AVG_PREAD_NUM_SQL=`echo "$PREAD_CNT / $EXEC_CNT" |bc` \
             -v V_CPU_AVG="$V_CPU_AVG" \
             -v V_CPU_MAX="$V_CPU_MAX" \
             -v V_CPU_MIN="$V_CPU_MIN" \
             -v V_RedoMB_SEC=`echo "scale=2; ( $V_RedoWB ) / $_DTM / ( 1024 * 1024 ) " |bc -l` \
             -v V_RedoWC_SEC=`echo "scale=0; ( $V_RedoWC ) / $_DTM " |bc -l` \
             -v V_COMMIT=`echo " $V_COMMIT / $_DTM " |bc` \
             '{ printf( ">> | %s| %s| %6s| %6s| %6s| %6s| %8s| %8s| %8s| %8s| %8s| %8s| %8s| %10s| %6s| %8s| %8s| %8s| %8s| %8s| %6s| %8s| %6s| %s|\n", \
                  V_STM, V_DTM, \
                  V_MX_RUNT_AVG, V_MX_READY_AVG, V_MX_RUNT_MAX, V_MX_READY_MAX, \
                  V_IS_LOCK_AVG, V_IX_LOCK_AVG, V_IS_LOCK_MAX, V_IX_LOCK_MAX, \
                  V_PREAD_SEC, V_PREAD_MB_SEC, \
                  V_AVG_PREAD_US, V_PREAD_CNT_SEC, V_EXEC_CNT_SEC, V_AGV_EXEC_US, V_AVG_PREAD_NUM_SQL, \
                  V_CPU_AVG, V_CPU_MAX, V_CPU_MIN, V_RedoMB_SEC, V_RedoWC_SEC, V_COMMIT, \
                  "get page(disk)" \
                  ) }'


