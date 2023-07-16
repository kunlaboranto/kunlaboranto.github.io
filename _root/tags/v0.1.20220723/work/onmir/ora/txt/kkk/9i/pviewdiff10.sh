#!/bin/sh

TBL="$1"

function doIt_
{
    #SQLCMD="$1"
    test "x$1" = "xORA9" && SQLCMD=".osws"
    test "x$1" = "xORA10" && SQLCMD=".osfs"
    test "x$1" = "xORA11" && SQLCMD="oss"
    test "x$1" = "xORA12" && SQLCMD=".os1s"

    ${SQLCMD} << EOF
desc $TBL
EOF
}

function doIt
{
    SQLCMD="$1"
    echo "${SQLCMD}> desc ${TBL}" > ${SQLCMD}.txt
    doIt_ ${SQLCMD} |expand -t 8 |sed -e "s/ [ ]*$//g" >> ${SQLCMD}.txt
}

 doIt ORA9
 doIt ORA10
 doIt ORA11

#sdiff -w 180 ORA9.txt ORA10.txt |expand -t 8
 sdiff -w 180 ORA9.txt ORA11.txt |expand -t 8 |tee aa
 sdiff -w 180 ORA11.txt ORA10.txt |expand -t 8 |tee bb


