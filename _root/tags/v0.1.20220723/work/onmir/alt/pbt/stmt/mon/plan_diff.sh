#!/bin/sh 

FA=$1

if [ ! -f $FA ]
then
    FA=$FA.sql
fi

FB=`grep SQL_ID $FA |sed -e "s/^.*\[//g" |sed -e "s/\].*$//g"`

if [ "x"$FB != "x" ]
then
    cp -p $FA $FB.sql
    F=$FB.sql
else
    F=$FA
fi



is1 -silent -f $F |grep -v TUPLE_SIZE: > 0.res 2>&1
is2 -silent -f $F |grep -v TUPLE_SIZE: > 1.res 2>&1
#isor98 -silent -f $F > 1.res 2>&1

diff 0.res 1.res
res=$?

DT=`date "+%Y%m%d_%H%M%S"`
#echo "################################################################################"
echo ">> "
if [ $res = "0" ]
then
    echo "[$DT] OK.. SAME"
    echo ""
    DST="./DONE"
else
    echo "[$DT] !! TODO NOT SAME !!"
    echo ""
    DST="./TODO"
fi

if [ "x"$FB != "x" ]
then
    if [ -f ./$DST/$F ]
    then
        cmp $F ./$DST/$F > /dev/null
        DF=$?
        if [ $DF != "0" ]
        then
            mv ./$DST/$F ./$DST/${F}.$DT
        fi
    fi

    mv $F ./$DST/.

    ls -l */${F}*
fi

