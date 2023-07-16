#!/bin/sh

function run
{
    FN="$1"
    STR="$2"
    #STR="latch free: drdb tbs list"

    #STM=`grep " 09:..:..\] EVENT= \[.*AVERAGE_WAIT" ${FN} |tail -1 |sed -e "s/= [ ]*\[/|/g" |sed -e "s/\] [ ]*/|/g" |sed -e "s/^.//g" |awk '{print $1}'`
    # |awk '{ sum += $1; num++; max  = max > $1 ? max : $1 } END { printf "sum=%.2f\n", sum; printf "num=%d\n",num; printf "avg=%.2f\n",sum/num ; printf "max=%.2f", max }'

    STM=`grep " 09:..:..\] EVENT= \[.*AVERAGE_WAIT" ${FN} |head -1 | sed -e "s/\].*//g" |sed -e "s/^.//g" |awk '{print $2}' |sed -e "s;/;.;g"`
   #ETM=`grep " 17:..:..\] EVENT= \[.*AVERAGE_WAIT" ${FN} |tail -1 | sed -e "s/\].*//g" |sed -e "s/^.//g" |awk '{print $2}' |sed -e "s;/;.;g"`
   #EDT=`grep " 17:..:..\] EVENT= \[.*AVERAGE_WAIT" ${FN} |tail -1 | sed -e "s/\].*//g" |sed -e "s/^.//g" |awk '{print $1" "$2}' `
    ETM=`grep " 10:..:..\] EVENT= \[.*AVERAGE_WAIT" ${FN} |tail -1 | sed -e "s/\].*//g" |sed -e "s/^.//g" |awk '{print $2}' |sed -e "s;/;.;g"`
    EDT=`grep " 10:..:..\] EVENT= \[.*AVERAGE_WAIT" ${FN} |tail -1 | sed -e "s/\].*//g" |sed -e "s/^.//g" |awk '{print $1" "$2}' `

    SVAL=`grep "${STM}\] EVENT= \[.*${STR}.*AVERAGE_WAIT.*" ${FN} |sed -e "s/^.*TIME_WAITED= \[//g" |sed -e "s/\].*//g"`
    EVAL=`grep "${ETM}\] EVENT= \[.*${STR}.*AVERAGE_WAIT.*" ${FN} |sed -e "s/^.*TIME_WAITED= \[//g" |sed -e "s/\].*//g"`

    SSUM=`grep "${STM}\] EVENT= \[.*AVERAGE_WAIT" ${FN} |sed -e "s/^.*TIME_WAITED= \[//g" |sed -e "s/\].*//g" |awk '{ sum += $1; num++; max  = max > $1 ? max : $1 } END { printf "%.2f\n", sum }'`
    ESUM=`grep "${ETM}\] EVENT= \[.*AVERAGE_WAIT" ${FN} |sed -e "s/^.*TIME_WAITED= \[//g" |sed -e "s/\].*//g" |awk '{ sum += $1; num++; max  = max > $1 ? max : $1 } END { printf "%.2f\n", sum }'`

    DSUM=`echo "${ESUM} - ${SSUM}" |bc `
    DVAL=`echo "${EVAL} - ${SVAL}" |bc `

    #DPCT=`echo "100 * ${DVAL} / ${DSUM}" |bc -l`
    DPCT=`echo "scale=2; 100 * ${DVAL} / ${DSUM}" |bc -l`

    SVAL2=`grep "${STM}\] EVENT= \[.*${STR}.*AVERAGE_WAIT.*" ${FN} |sed -e "s/^.*TOTAL_WAITS= \[//g" |sed -e "s/\].*//g"`
    EVAL2=`grep "${ETM}\] EVENT= \[.*${STR}.*AVERAGE_WAIT.*" ${FN} |sed -e "s/^.*TOTAL_WAITS= \[//g" |sed -e "s/\].*//g"`
    DVAL2=`echo "${EVAL2} - ${SVAL2}" |bc `
    #UVAL2=`echo "scale=2; 1000 * 1000 * ${DVAL} / ${DVAL2}" |bc -l`
    UVAL2=`echo "scale=6; ${DVAL} / ${DVAL2}" |bc -l`

    #echo "${FN}: [$EDT] EVENT= [${STR}] = \t${DPCT} ,  ( = $DVAL / $DSUM )"
    printf "${FN}: [$EDT] EVENT= [%30s] = %5s %s,  ( = %10s / %11.0f ) [U,%10.6f,C,%10s]\n" "${STR}" "${DPCT}" "%" "${DVAL}" "${DSUM}" "${UVAL2}" "${DVAL2}"
}

if [ "x$1" != "x" ]
then
    F="$1"
    echo ""
    run "$F" "latch free: drdb tbs list"
    run "$F" "latch: buffer busy waits"
    run "$F" "db file single page read"
    run "$F" "db file multi page read"
    run "$F" "latch free: drdb LRU list"
    exit
fi

for F in `ls ALTIMON_DB01.log_????`
do
    echo ""
    run "$F" "latch free: drdb tbs list"
    run "$F" "latch: buffer busy waits"
    run "$F" "db file single page read"
    run "$F" "db file multi page read"
    run "$F" "latch free: drdb LRU list"
done



