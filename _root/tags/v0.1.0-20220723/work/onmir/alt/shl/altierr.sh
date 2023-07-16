#!/bin/sh

LEN=`echo "$1" |wc -c`

if [ $LEN -gt 8 ]
then
    if [ $LEN -gt 9 ]
    then
        N1=`echo "obase=16; $1 " |bc |cut -c 1-5`
        N1="0x$N1"
    else
        N1=`echo "obase=16; $1 " |bc |cut -c 1-4`
        N1="0x0$N1"
    fi
    run="altierr $N1" 
    echo ${run}
    ${run}
else
    altierr $*
fi


exit 0
