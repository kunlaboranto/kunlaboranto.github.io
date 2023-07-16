#!/bin/sh

#INTERVAL=2
INTERVAL=9
#INTERVAL=10

HOSTNAME=`/usr/bin/hostname`
DIR=$HOME/work/DBA/mon

export ISQL_CONNECTION=IPC

function doInit
{
is -silent << EOF
    drop table mon_buffpool_stat ;
    drop table mon_sysstat ;
    create table mon_buffpool_stat tablespace SYS_TBS_MEM_DATA as select sysdate created, a.* from v\$buffpool_stat a;
    create table mon_sysstat tablespace SYS_TBS_MEM_DATA as select sysdate created, a.* from v\$sysstat a;
    create index ix_mon_sysstat_01 on mon_sysstat ( seqnum );

    --delete from mon_buffpool_stat;
    --insert into mon_buffpool_stat select sysdate, a.* from v\$buffpool_stat a;
    --delete from mon_sysstat;
    --insert into mon_sysstat select sysdate, a.* from v\$sysstat a;
    --commit;
EOF
}

function doIt
{
is -silent << EOF
    set linesize 3000;
    set colsize 0;
    select
           to_char(sysdate, 'YYYY/MM/DD HH:MI:SS')
         --
         , (SELECT ROUND((ALLOCATED_PAGE_COUNT*PAGE_SIZE)/1024/1024,0) FROM V\$TABLESPACES WHERE NAME IN ('SYS_TBS_DISK_UNDO')) ALLOC
         , (a.READ_PAGES - b.READ_PAGES) 'READ'
         , (a.GET_PAGES - b.GET_PAGES) GET
         --
         , (a.CREATE_PAGES - b.CREATE_PAGES) CRT
         , (a.FIX_PAGES - b.FIX_PAGES) FIX
         , (a.VICTIM_SEARCH_COUNT - b.VICTIM_SEARCH_COUNT) 'VSC'
         , (a.PREPARE_VICTIMS - b.PREPARE_VICTIMS) 'PrepVictim'
         , (a.LRU_SEARCHS - b.LRU_SEARCHS) 'LRUS'
         --
         , a.PREPARE_LIST_PAGES 'PreLP'
         , a.FLUSH_LIST_PAGES 'FlushLP'
         , a.CHECKPOINT_LIST_PAGES 'ChkptLP'
         , a.HOT_LIST_PAGES 'HotLP'
         --, (a.LRU_TO_FLUSHS - b.LRU_TO_FLUSHS) 'LRU_TO_FLUSHS'
         , ( select (a.value-b.value) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'execute success count' ) ES
         --
         , ( select (a.value-b.value) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'execute failure count' ) EF
         , ( select (a.value-b.value) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'prepare success count' ) PS
         , ( select (a.value-b.value) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'lock acquired count' ) 'LockA'
         , ( select (a.value-b.value) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'lock released count' ) 'LockR'
         , ( select (a.value-b.value) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'session commit' ) 'Commit'
         --
         , ( select (a.value-b.value) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'write redo log count' ) 'RedoWC'
         , ( select round((a.value/1024-b.value/1024),0) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'write redo log bytes' ) 'RedoKB'
         , ( select round((a.value/1024-b.value/1024),0) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'byte received via inet' ) 'TcpR'
         , ( select round((a.value/1024-b.value/1024),0) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'byte sent via inet' ) 'TcpS'
         , ( SELECT ROUND(SUM(REPLACE_FLUSH_PAGES + CHECKPOINT_FLUSH_PAGES + OBJECT_FLUSH_PAGES)*8/1024,0) FROM V\$FLUSHER ) FlushMB
         --
         , ( select (a.value-b.value) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'update retry count' ) 'RetryU'
         , ( select (a.value-b.value) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'delete retry count' ) 'RetryD'
         , ( select (a.value-b.value) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'lock row retry count' ) 'RetryL'
         , ( select (a.value-b.value) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'disk table cursor full scan count' ) 'FTS'
         , ( select (a.value-b.value) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'memory table cursor full scan count' ) 'FTS_MEM'
         --
         , ( SELECT COUNT(*) FROM V\$TXSEGS ) 'UNDO_NUMS'
         --, ( SELECT ROUND(SUM(TOTAL_EXTENT_COUNT)*256/1024,0) FROM V\$UDSEGS ) 'UNDO_USED'
         , ( ( SELECT ROUND(SUM(TOTAL_EXTENT_COUNT)*256/1024,0) FROM V\$UDSEGS )
           + ( SELECT ROUND(SUM(TOTAL_EXTENT_COUNT)*256/1024,0) FROM V\$TSSEGS ) ) UNDO_USED
         , ( SELECT ROUND(NVL(SUM(U.TOTAL_EXTENT_COUNT + U2.TOTAL_EXTENT_COUNT),0)*256/1024,0)
               FROM V\$TXSEGS T
                    INNER JOIN V\$UDSEGS U ON U.TXSEG_ENTRY_ID = T.ID
                    INNER JOIN V\$TSSEGS U2 ON U2.TXSEG_ENTRY_ID = T.ID
           ) UNDO_CURRENT
         --, 0 UNDO_CURRENT
         , a.VICTIM_FAILS 'VF'
         , (SELECT COUNT(*) FROM V\$SERVICE_THREAD WHERE TYPE != 'IPC' AND STATE = 'EXECUTE') MX
         , (SELECT COUNT(*) FROM V\$STATEMENT WHERE EXECUTE_FLAG = 1 AND EVENT NOT IN ( 'no wait event', 'db file single page read', 'db file multi page read' ) ) BLOCKED
         , (SELECT ROUND(((TOTAL_PAGE_COUNT-ALLOCATED_PAGE_COUNT)*PAGE_SIZE)/1024/1024,0) FROM V\$TABLESPACES WHERE NAME IN ('SYS_TBS_DISK_UNDO')) FREE
         , ( select (SUM(a.value)-SUM(b.value)) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name like 'elapsed time:%hard%prepare%' ) TM_HARD_PREPARE
         , ( select (SUM(a.value)-SUM(b.value)) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name like 'elapsed time:%soft%prepare' ) TM_SOFT_PREPARE
      FROM V\$BUFFPOOL_STAT A, MON_BUFFPOOL_STAT B
     WHERE 1=1
       AND A.ID = B.ID
;
EOF
}

########################################
# MAIN
########################################

doInit

D01_P=0 ; D02_P=0 ; D03_P=0 ; D04_P=0 ; D05_P=0
D06_P=0 ; D07_P=0 ; D08_P=0 ; D09_P=0 ; D10_P=0
D11_P=0 ; D12_P=0 ; D13_P=0 ; D14_P=0 ; D15_P=0
D16_P=0 ; D17_P=0 ; D18_P=0 ; D19_P=0 ; D20_P=0
D21_P=0 ; D22_P=0 ; D23_P=0 ; D24_P=0 ; D25_P=0
D26_P=0 ; D27_P=0 ; D28_P=0 ; D29_P=0 ; D30_P=0
D31_P=0 ; D32_P=0 ; D33_P=0 ; D34_P=0 ; D35_P=0
D36_P=0 ; D37_P=0 ; D38_P=0 ; D39_P=0 ; D40_P=0

CUR_TIME=""
CUR_TIME_PRE=""

while :
do
    YYYY=`date "+%Y"`

    CUR_TIME_PRE=$CUR_TIME
    CUR_TIME=`date '+%Y%m%d'`
    if [ "x$CUR_TIME_PRE" != "x$CUR_TIME" ]
    then
        # Need Daily Init
        doInit
    fi

    sleep $INTERVAL

    #MSG=`doIt |grep "^$YYYY"`
    #echo "MSG="$MSG ; exit

    MSG=`doIt |grep "^$YYYY" |sed -e "s;$YYYY/;;g"`
    DT=`echo $MSG |awk '{print $1" "$2}'`

    D01=`echo $MSG |awk '{print $3}'`; D01_D=`expr $D01 - $D01_P`; D01_P=$D01
    D02=`echo $MSG |awk '{print $4}'`; D02_D=`expr $D02 - $D02_P`; D02_P=$D02
    D03=`echo $MSG |awk '{print $5}'`; D03_D=`expr $D03 - $D03_P`; D03_P=$D03
    D04=`echo $MSG |awk '{print $6}'`; D04_D=`expr $D04 - $D04_P`; D04_P=$D04
    D05=`echo $MSG |awk '{print $7}'`; D05_D=`expr $D05 - $D05_P`; D05_P=$D05
    D06=`echo $MSG |awk '{print $8}'`; D06_D=`expr $D06 - $D06_P`; D06_P=$D06
    D07=`echo $MSG |awk '{print $9}'`; D07_D=`expr $D07 - $D07_P`; D07_P=$D07
    D08=`echo $MSG |awk '{print $10}'`; D08_D=`expr $D08 - $D08_P`; D08_P=$D08
    D09=`echo $MSG |awk '{print $11}'`; D09_D=`expr $D09 - $D09_P`; D09_P=$D09
    D10=`echo $MSG |awk '{print $12}'`; D10_D=`expr $D10 - $D10_P`; D10_P=$D10
    D11=`echo $MSG |awk '{print $13}'`; D11_D=`expr $D11 - $D11_P`; D11_P=$D11
    D12=`echo $MSG |awk '{print $14}'`; D12_D=`expr $D12 - $D12_P`; D12_P=$D12
    D13=`echo $MSG |awk '{print $15}'`; D13_D=`expr $D13 - $D13_P`; D13_P=$D13
    D14=`echo $MSG |awk '{print $16}'`; D14_D=`expr $D14 - $D14_P`; D14_P=$D14
    D15=`echo $MSG |awk '{print $17}'`; D15_D=`expr $D15 - $D15_P`; D15_P=$D15
    D16=`echo $MSG |awk '{print $18}'`; D16_D=`expr $D16 - $D16_P`; D16_P=$D16
    D17=`echo $MSG |awk '{print $19}'`; D17_D=`expr $D17 - $D17_P`; D17_P=$D17
    D18=`echo $MSG |awk '{print $20}'`; D18_D=`expr $D18 - $D18_P`; D18_P=$D18
    D19=`echo $MSG |awk '{print $21}'`; D19_D=`expr $D19 - $D19_P`; D19_P=$D19
    D20=`echo $MSG |awk '{print $22}'`; D20_D=`expr $D20 - $D20_P`; D20_P=$D20
    D21=`echo $MSG |awk '{print $23}'`; D21_D=`expr $D21 - $D21_P`; D21_P=$D21
    D22=`echo $MSG |awk '{print $24}'`; D22_D=`expr $D22 - $D22_P`; D22_P=$D22
    D23=`echo $MSG |awk '{print $25}'`; D23_D=`expr $D23 - $D23_P`; D23_P=$D23
    D24=`echo $MSG |awk '{print $26}'`; D24_D=`expr $D24 - $D24_P`; D24_P=$D24
    D25=`echo $MSG |awk '{print $27}'`; D25_D=`expr $D25 - $D25_P`; D25_P=$D25
    D26=`echo $MSG |awk '{print $28}'`; D26_D=`expr $D26 - $D26_P`; D26_P=$D26
    D27=`echo $MSG |awk '{print $29}'`; D27_D=`expr $D27 - $D27_P`; D27_P=$D27
    D28=`echo $MSG |awk '{print $30}'`; D28_D=`expr $D28 - $D28_P`; D28_P=$D28
    D29=`echo $MSG |awk '{print $31}'`; D29_D=`expr $D29 - $D29_P`; D29_P=$D29
    D30=`echo $MSG |awk '{print $32}'`; D30_D=`expr $D30 - $D30_P`; D30_P=$D30
    D31=`echo $MSG |awk '{print $33}'`; D31_D=`expr $D31 - $D31_P`; D31_P=$D31
    D32=`echo $MSG |awk '{print $34}'`; D32_D=`expr $D32 - $D32_P`; D32_P=$D32
    D33=`echo $MSG |awk '{print $35}'`; D33_D=`expr $D33 - $D33_P`; D33_P=$D33
    D34=`echo $MSG |awk '{print $36}'`; D34_D=`expr $D34 - $D34_P`; D34_P=$D34
    D35=`echo $MSG |awk '{print $37}'`; D35_D=`expr $D35 - $D35_P`; D35_P=$D35
    D36=`echo $MSG |awk '{print $38}'`; D36_D=`expr $D36 - $D36_P`; D36_P=$D36
    D37=`echo $MSG |awk '{print $39}'`; D37_D=`expr $D37 - $D37_P`; D37_P=$D37

    if [ $D15_D = 0 ]
    then
        D36_A=0
    else
        D36_A=`echo "scale=0;( $D36_D / ( $D15_D ) )" |bc -l`
    fi

    if [ $D13_D = 0 ]
    then
        D37_A=0
    else
        D37_A=`echo "scale=0;( $D37_D / ( $D13_D ) )" |bc -l`
    fi

    #D90=`echo "scale=2;( 1 - $D02_D * 100 / ( $D03_D + $D05_D ) )" |bc -l`; D90_D=`echo "scale=2;$D90 - $D90_P"|bc -l`; D90_P=$D90
    D90=`echo "scale=2;( 100 - $D02_D * 100 / ( $D03_D + $D05_D ) )" |bc -l`
    if [ $D02_D = 0 -a $D04_D = 0 ]
    then
        D91=0
    else
        D91=`echo "scale=2;( $D08_D * 1 / ( $D02_D + $D04_D ) )" |bc -l`
    fi

    LOG_DIR=`grep "^LOG_DIR" $ALTIBASE_HOME/conf/altibase.properties |awk '{print $3}' |sed -e "s;?;$ALTIBASE_HOME;g" `
    LOG_CNT=`ls $LOG_DIR |grep logfile |wc -l |sed -e "s/ //g"`

    echo "[$DT] READ=$D02_D GET=$D03_D FIX=$D05_D CRT=$D04_D VSC=$D06_D PVictim=$D07_D P7=$D09 F7=$D10 C7=$D11 HOT=$D12 LRUS=$D08_D ($D91) HIT=$D90" >> $DIR/logs/$HOSTNAME"_STAT_"$CUR_TIME
    echo "[$DT] ES=$D13_D EF=$D14_D PS=$D15_D LockA=$D16_D LockR=$D17_D Commit=$D18_D RedoWC=$D19_D RedoKB=$D20_D TcpR=$D21_D TcpS=$D22_D FlushMB=$D23_D LOG=$LOG_CNT " >> $DIR/logs/$HOSTNAME"_STAT_"$CUR_TIME
    #echo "[$DT] FTS=[D,$D27_D,M,$D28_D] Retry=[U,$D24_D,D,$D25_D,L,$D26_D] VictimF=[$D32,D,$D32_D] UNDO=[$D01,U,$D30,D,$D30_D,C,$D31,D,$D31_D,F,$D35,D,$D35_D,TX,$D29,RunT,$D33,Wait,$D34] " >> $DIR/logs/$HOSTNAME"_STAT_"$CUR_TIME
    #echo "[$DT] FTS=[D,$D27_D,M,$D28_D] Retry=[U,$D24_D,D,$D25_D,L,$D26_D] UNDO=[$D01,U,$D30,D,$D30_D,C,$D31,D,$D31_D,F,$D35,D,$D35_D,TX,$D29,RunT,$D33,Wait,$D34] " >> $DIR/logs/$HOSTNAME"_STAT_"$CUR_TIME
    #echo "[$DT] FTS=[D,$D27_D,M,$D28_D] Retry=[U,$D24_D,D,$D25_D,L,$D26_D] UNDO=[$D01,U,$D30,D,$D30_D,F,$D35,D,$D35_D,C,$D31,D,$D31_D,TX,$D29,RunT,$D33,Wait,$D34] " >> $DIR/logs/$HOSTNAME"_STAT_"$CUR_TIME
    echo "[$DT] FTS=[D,$D27_D,M,$D28_D] PLAN=[H,$D36_D,$D36_A,S,$D37_D,$D37_A] UNDO=[$D01,U,$D30,D,$D30_D,F,$D35,D,$D35_D,C,$D31,D,$D31_D,TX,$D29,RunT,$D33,Wait,$D34] " >> $DIR/logs/$HOSTNAME"_STAT_"$CUR_TIME
    echo "--" >> $DIR/logs/$HOSTNAME"_STAT_"$CUR_TIME
done
