#!/bin/sh

#INTERVAL=10
 INTERVAL=60
#INTERVAL=120

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
> /tmp/$LOGNAME/_90_epoch_time.pl

perl /tmp/$LOGNAME/_90_epoch_time.pl "$*"
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
    .is1s <<EOF
SELECT 'CUT='||ROUND( ( TO_DATE('$2','YYYY/MM/DD HH24:MI:SS') - TO_DATE('$1','YYYY/MM/DD HH24:MI:SS') ) * 24 * 3600 , 0 ) FROM DUAL;
EOF
}


function doMain
{
# sleep 9 ; return;

.is1s << EOF

EXEC GDR_SP_SAMPLE_MAIN;

EXEC GDR_SP_INS_SQL_PLAN;

UPDATE GDR_HIST_SQL_PLAN 
   SET XLOG_NAME = NVL( GDR_SF_XLOG_NAME( SQL_TEXT, SQL_TEXT2 ), ' '), XLOG_NAME_KO = GDR_SF_XLOG_NAME( SQL_TEXT, SQL_TEXT2, 'KO' ) 
 WHERE XLOG_NAME IS NULL 
   --AND GDR_SF_XLOG_NAME( SQL_TEXT, SQL_TEXT2 ) IS NOT NULL
;

COMMIT;
EOF

}

CMD="doMain"
DT=`date "+%Y%m%d"`

# exact_sleep
function doLoop
{

ix=0
while :
do
	STM=`date "+%Y/%m/%d %H:%M:%S"`
	#STM=`date "+%Y%m%d%H%M%S"`

	DT=`date "+%Y%m%d"`

	ix=`expr $ix + 1`
    if [ $ix -gt 11520 ]	# 8 day
    # if [ $ix -gt 10080 ]	# 7 day
    # if [ $ix -gt 2880 ]	# 2 day
    # if [ $ix -gt 1440 ]	# 1 Day
    # if [ $ix -gt 720 ]   	# 0.5 Day
    # if [ $ix -gt 120 ]
    # if [ $ix -gt 60 ]
    then
        echo "[$DT] ($IX) GDMON4ALT END.."
        exit
    fi

	${CMD} |sed -e "s/^/    /g"

	ETM=`date "+%Y/%m/%d %H:%M:%S"`
	#ETM=`date "+%Y%m%d%H%M%S"`

	DTM=`doDTM "$STM" "$ETM" |grep ^CUT= |sed -e "s/^CUT=//g" |sed -e "s/ //g" `
	echo "[$STM] ($ix) elapsed time : $DTM"
	REMAIN_TIME=`echo "$INTERVAL - $DTM" |bc`
	if [ $REMAIN_TIME -ge 1 ]
	then
		echo "sleep $REMAIN_TIME" |sh -v
	fi
done
}


#doLoop |tee -a ./gdmon4alt.log_${DT}
doLoop >> ./gdmon4alt.log_${DT} 2>&1


