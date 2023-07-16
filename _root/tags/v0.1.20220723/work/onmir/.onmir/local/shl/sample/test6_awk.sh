#!/bin/sh

test6() {
    FILE=$1
    REV=`echo $FILE |sed -e "s/_.*//g"`
	grep "^LOOP=" $FILE |sed -e "s/tid=.*//g" |sed -e "s/^.*=//g" | awk -v REV=$REV '
    BEGIN {
        THR = 4; 
        R1 = 0;
        R2 = 0;
        R3 = 0;
    }
    {
        if ( NR <= THR )
        {
            R1 = R1 + $1;
        }
        else if ( NR <= THR * 2 )
        {
            R2 = R2 + $1;
        }
        else if ( NR <= THR * 3 )
        {
            R3 = R3 + $1;
        }
	}
    END {
        printf( "%s=[I,%f,S.%f,C.%f]\n", "result of "REV, R1/THR, R2/THR, R3/THR );
    }
    '
}

# LOOP=5000000, i=2500000, Elap=1.501572371

if [ "x"$1 == "x" ]
then
    for f in `ls -1 r[1-9]*.txt`
    do
        test6 $f
    done
else
    test6 $1
fi

exit 0
