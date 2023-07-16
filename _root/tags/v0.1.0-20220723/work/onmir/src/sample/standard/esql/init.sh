#!/bin/sh

#rm -f *.log
sync
sync

if [ "x$GOLDILOCKS_HOME" != "x" ]
then
    ${GOLDILOCKS_HOME}/bin/gsqlnet sys gliese as sysdb < chkpt.sql
fi

#exit 0

if [ "x$ORACLE_HOME" != "x" ]
then
    ${ORACLE_HOME}/bin/sqlplus sys/manager as sysdba < chkpt.sql
fi

if [ "x$ALTIBASE_HOME" != "x" ]
then
    ${ALTIBASE_HOME}/bin/isql -sysdba -s localhost -u sys -p manager < chkpt.sql
fi

