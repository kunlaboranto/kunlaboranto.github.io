#!/bin/sh

TNAME="BT"
test "x$1" != "x" && TNAME=$1

SQLCMD="gsqlnet test test --dsn=G1N2"
test "x$USER" == "xaltibase" && SQLCMD="isql -u test -p test -s localhost"
test "x$USER" == "xoracle" && SQLCMD="sqlplus test/test@orcl"

USLEEP_COST=50000			# gsql 접속후 cnt 수행시간

CNT=0
CNT_P=0
CNT_D=0

TM=0
TM_P=0
TM_D=0

####################
# FUNCTION
####################

function doClean
{
$SQLCMD << EOF
drop table BT ;
create table BT ( key number(10), data char(100), d2 char(512), d3 char(512) ) ;

drop table tb_test1;
create table tb_test1
(
    c1  number(10),
    c2  char(10),
    c3  number(10),
    c4  char(10),
    c5  char(10),
    c6  char(10),
    c7  char(10),
    c8  char(10),
    c9  number(10),
    c10 date
);

--alter table tb_test1 add constraint pk_tb_test1 primary key ( c1 );
--create index TB_TEST1_IDX on TB_TEST1 (c3 desc, c1 asc);

commit;
EOF
}

function doOne
{
$SQLCMD << EOF
select to_char(systimestamp,'YYYY/MM/DD HH24:MI:SS.FF6') ||' $TNAME = '||count(*) from $TNAME ;
EOF
}

####################
# MAIN
####################

test "x$2" != "x" && doClean

# Check Some Error ( ex. TABLE NOT_FOUND )
RES=`doOne 2>&1`
chk=`echo $RES |grep -e "ERR-" -e "ORA-" |wc -l`
if [ "x"$chk != "x0" ]
then
	echo "$RES" 
	sleep 2
	exit 1
fi

while :
do
	# 2017/11/3323 11:18:31.503713 COUNT = 100000 (0)
	RES=`doOne |grep "^2017" |sed -e "s/ [ ]*$//g"`

	CNT_P=$CNT
	CNT=`echo $RES |sed -e "s/^.* //" `
	CNT_D=`echo $CNT - $CNT_P |bc -l`

	TM_P=$TM
	TM=`echo $RES |sed -e "s/^.*://" |sed -e "s/ .*$//g"`
	TM_D=`echo "$TM - $TM_P" |bc`
	TPS=`echo "$CNT_D/$TM_D" |bc`

	echo "$RES [D,$CNT_D,TPS,$TPS]"

	#sleep 1
	usleep `echo "1000000 * 1 - $USLEEP_COST" |bc`
done
