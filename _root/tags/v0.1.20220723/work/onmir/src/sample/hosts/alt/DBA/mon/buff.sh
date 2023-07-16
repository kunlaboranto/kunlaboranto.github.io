#!/bin/sh

#INTERVAL=2
INTERVAL=9
#INTERVAL=10

#CUR_TIME=`date '+%b%d_%H%M%S'`
CUR_TIME=`date '+%Y%m%d'`
HOSTNAME=`/usr/bin/hostname`
DIR=$HOME/work/DBA/mon

YYYY=`date "+%Y"`

function doI()
{
is -silent << EOF
    set linesize 3000;
    set colsize 0;
    select 
           to_char(sysdate, 'YYYY/MM/DD HH:MI:SS')
         --
         , (select round((ALLOCATED_PAGE_COUNT*page_size)/1024/1024,0) from v\$tablespaces where name in ('SYS_TBS_DISK_UNDO')) alloc
         , (a.READ_PAGES - b.READ_PAGES) 'READ'
         , (a.GET_PAGES - b.GET_PAGES) GET
         --
         , (a.CREATE_PAGES - b.CREATE_PAGES) CRT
         , (a.FIX_PAGES - b.FIX_PAGES) FIX
         , (a.VICTIM_SEARCH_COUNT - b.VICTIM_SEARCH_COUNT) 'VSC'
         , (a.PREPARE_VICTIMS - b.PREPARE_VICTIMS) 'PrepVictim'
         , (a.LRU_SEARCHS - b.LRU_SEARCHS) 'LRUS'
         --
         , (a.PREPARE_LIST_PAGES - b.PREPARE_LIST_PAGES) 'PreLP'
         , (a.FLUSH_LIST_PAGES - b.FLUSH_LIST_PAGES) 'FlushLP'
         , (a.CHECKPOINT_LIST_PAGES - b.CHECKPOINT_LIST_PAGES) 'ChkptLP'
         , (a.HOT_LIST_PAGES - b.HOT_LIST_PAGES) 'HotLP'
         --, (a.LRU_TO_FLUSHS - b.LRU_TO_FLUSHS) 'LRU_TO_FLUSHS'
         , ( select (a.value-b.value) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'execute success count' ) ES
         --
         , ( select (a.value-b.value) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'execute failure count' ) EF
         , ( select (a.value-b.value) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'prepare success count' ) PS
         , ( select (a.value-b.value) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'lock acquired count' ) 'LockA'
         , ( select (a.value-b.value) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'lock released count' ) 'LockR'
         -- 17
         , ( select (a.value-b.value) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'session commit' ) 'Commit'
         , ( select (a.value-b.value) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'write redo log count' ) 'RedoWC'
         , ( select round((a.value/1024-b.value/1024),0) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'write redo log bytes' ) 'RedoKB'
         , ( select round((a.value/1024-b.value/1024),0) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'byte received via inet' ) 'TcpR'
         , ( select round((a.value/1024-b.value/1024),0) from v\$sysstat a, mon_sysstat b where a.seqnum = b.seqnum and a.name = 'byte sent via inet' ) 'TcpS'
         , ( SELECT ROUND(SUM(REPLACE_FLUSH_PAGES + CHECKPOINT_FLUSH_PAGES + OBJECT_FLUSH_PAGES)*8/1024,0) FROM V\$FLUSHER ) FlushMB
      from v\$buffpool_stat a, mon_buffpool_stat b
     where 1=1
       and a.id = b.id
;
EOF
}

is -silent << EOF
    --create table mon_buffpool_stat as select * from v$buffpool_stat;
    --create table mon_sysstat as select * from v$sysstat;

    delete from mon_buffpool_stat;
    insert into mon_buffpool_stat select * from v\$buffpool_stat;
    delete from mon_sysstat;
    insert into mon_sysstat select * from v\$sysstat;

    commit;
EOF

D01_P=0 ; D02_P=0 ; D03_P=0 ; D04_P=0 ; D05_P=0
D06_P=0 ; D07_P=0 ; D08_P=0 ; D09_P=0 ; D10_P=0
D11_P=0 ; D12_P=0 ; D13_P=0 ; D14_P=0 ; D15_P=0
D16_P=0 ; D17_P=0 ; D18_P=0 ; D19_P=0 ; D20_P=0
D21_P=0 ; D22_P=0 ; D23_P=0 ; D25_P=0 ; D25_P=0

while :
do
    CUR_TIME=`date '+%Y%m%d'`
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

    LOG_DIR=`grep "^LOG_DIR" $ALTIBASE_HOME/conf/altibase.properties |awk '{print $3}' |sed -e "s;?;$ALTIBASE_HOME;g" `
    # LOG_CNT=`find $LOG_DIR/. -name "logfile*" -print | wc -l`
    LOG_CNT=`ls $LOG_DIR/logfile* | wc -l`

    echo "[$DT] UNDO=$D01 ($D01_D) READ=$D02_D GET=$D03_D CRT=$D04_D FIX=$D05_D VSC=$D06_D PVictim=$D07_D LRUS=$D08_D P7=$D09_D F7=$D10_D C7=$D11_D HOT=$D12_D " >> $DIR/logs/$HOSTNAME"_STAT_"$CUR_TIME
    echo "                 ES=$D13_D EF=$D14_D PS=$D15_D LockA=$D16_D LockR=$D17_D Commit=$D18_D RedoWC=$D19_D RedoKB=$D20_D TcpR=$D21_D TcpS=$D22_D FlushMB=$D23_D LOG=$LOG_CNT " >> $DIR/logs/$HOSTNAME"_STAT_"$CUR_TIME

done
