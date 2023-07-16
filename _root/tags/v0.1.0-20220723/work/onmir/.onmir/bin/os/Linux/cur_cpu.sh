#!/bin/sh

sTxt=$USER
test "x"$1 != "x" && sTxt=$1

ps -eLf |grep "$USER " |grep "$sTxt" |grep -v "\.sh" |grep -v grep |awk '{print "taskset -cp "$4}' |sh -v

exit 0

# 아래는 너무 복잡하다.

#for i in $(ps aux |awk '{print $2}') ; do  taskset -pc $i |awk '{print $6" "$2}' |grep -v "0 " ; done;

dbm_mon_cpu ()
{
    sTxt=$USER
    test "x"$1 != "x" && sTxt=$1

    #echo $sTxt && exit 0

    printf "%6s %6s %-20s %c %c %s\n" "CPU" "LWP" "CMD" "L" "C" "WCHAN"
    for i in $(ps -efL |grep $sTxt |grep -v PID |grep -v -E "sshd|vim|cat| sh|bash|java|gnome" |awk '{print $4}' )
    do
        PID=$i
        res=`taskset -pc $PID 2>&1 |awk '{print $6" "$2}' |grep "'s$" |sed -e "s/'s$//g"`
        if [ "x"$? != "x0" ]
        then
            continue;
        fi

        CPU=`echo $res |cut -d' ' -f1`
        CMD=`cat /proc/$PID/comm 2>/dev/null`
        WCHAN=`cat /proc/$PID/wchan 2>/dev/null`

        # STAT = PSR + STATE
        STAT=`cat /proc/$PID/stat 2>/dev/null |awk '{ print $39" "$3 }'`
        PGRP=`cat /proc/$PID/stat 2>/dev/null |awk '{ print $5 }'`

        if [ "x$CMD" == "x" ]
        then
            continue;
        fi

        if [ "x"$PGRP == "x"$PID ]
        then
            echo ""
            #ps -L -p $PID -o pid,tid,psr,pcpu,ni,pri,time,stat,wchan
        fi

        printf "%6s %6d %-20s %c %c %s\n" $CPU $PID $CMD $STAT $WCHAN
    done
}

dbm_mon_cpu $*
