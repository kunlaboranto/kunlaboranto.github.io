#!/bin/bash

#
# show current running process   
#

TMP=/tmp/$USER
test -d $TMP || mkdir -p $TMP
GREP='grep --color=auto'


function pr()
{
    ps -el > $TMP/a.txt

    ppid=`cat $TMP/a.txt | awk '$2!="S" { print $5 }'`
    #ppid=`cat $TMP/a.txt | awk '$2=="Z" { print $5 }'`         # Zombi

    find=0
    for pid in $ppid
    do
        # 좀비프로세스를 색깔로 구분.
        ps -p $pid -ostate,pid,ppid,pri,nice,psr,pcpu,wchan,rss,vsz,start,time,cmd |grep -v PPID |$GREP "^Z"
        find=1
    done

    if [ $find == "1" ]
    then
        echo "S   PID  PPID PRI  NI PSR %CPU WCHAN    RSS    VSZ  STARTED     TIME CMD ( `date` )"
    fi

}

########################################
# MAIN
########################################

pr
# usleep 100 && pr

