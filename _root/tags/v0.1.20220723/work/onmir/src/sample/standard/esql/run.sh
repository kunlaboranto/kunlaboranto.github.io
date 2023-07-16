#!/bin/sh

if [ $# -lt 5 ]
then
    echo "usage] $0 [i/u/d/s] [totalCount] [processCount] [randomTag] [commitCount]"
    exit
fi

job=$1
total=$2
pcount=$3
rtag=$4
commit=$5
start=1
plus=`expr $2 / $3`
end=$plus
log="${job}_bmt_${pcount}.log"

if [ `expr $total % $pcount` -ne 0 ]
then
    echo "error] total count is wrong"
    exit 1;
fi

if [ -f $log ]
then
    rm -f $log
fi

#while :
while [ $end -le $total ]
do
    if [ $end -lt $total ]
    then
        echo "./bmt $job $start $end $rtag $commit >> $log &"
        ./bmt $job $start $end $rtag $commit >> $log &
    else
        echo "./bmt $job $start $end $rtag $commit >> $log"
        ./bmt $job $start $end $rtag $commit >> $log
    fi
    start=`expr $start + $plus`
    end=`expr $end + $plus`
    #if [ $end -gt $total ]
    #then
    #    exit 0;
    #fi
done

while :
do
    pcount=`ps -ef | grep $$ | grep -v grep | grep bmt | wc -l`
    if [ $pcount -eq 0 ]
    then
        break;1
    fi
    sleep 1
done

grep "TPS" $log
echo " Total TPS (Second) = " `grep "TPS" $log | awk 'BEGIN {sum=0;}{sum+=$5} END {print sum}'` "TPS"
