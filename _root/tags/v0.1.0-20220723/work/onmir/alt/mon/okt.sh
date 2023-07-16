#!/bin/sh

if [ "x$1" = "xf" ]
then
    DT=`date "+%Y/%m/%d %H:%M:%S"`
    # kcusage |grep -e ^T -e maxfile
    OUT=`kcusage |grep -e maxfile`
    echo "[$DT] $OUT" ; exit 0
fi


####################
# MAIN
####################

DT=`date "+%Y%m%d"`

FN="db01_MX_${DT}"
test "x$1" != "x" && FN="$1"

echo ""
#cat "${FN}" |grep ^MX |grep -v "Ready: [ ]*0" |grep -v "Ready:   [1]$"
cat "${FN}" |grep ^MX |grep -e "Ready:   [2-9]$" -e "Ready:  [^ ][2-9]$" -e "RunT:  [2-9]"

sleep 2
echo ""
cat "${FN}" |grep ^MX |grep -v "Ready: [ ]*0"

echo "@@ ${FN} @@"

if [ "x$1" = "x" ]
then
    echo ""
    echo "@@ db01_BATCH_${DT} @@"
    sleep 2
    grep "[1-9][0-9][0-9]*개" db01_BATCH_${DT}
fi

