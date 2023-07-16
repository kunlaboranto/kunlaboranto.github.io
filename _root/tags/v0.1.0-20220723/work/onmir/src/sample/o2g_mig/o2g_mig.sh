#!/bin/sh

export USER_="test"             # need 'export' for cascade
export PASS_="test"
export TRUNCATE_="Y"            # Y or N ( default )

# test "x" != "x$1" && TBL=$1
if [ "x" != "x$1" ]
then
    TBL=$1
else
    echo "Usage] sh $0 <table_name>"
    exit -1
fi

########################################
# DOWNLOAD
########################################

set -x
time sqlplus -S $USER_/$PASS_ @getdata ${TBL}
RC=$?
set +x

if [ $RC != 0 ] 
then
    echo "[ERROR] ${TBL} download fail. ($RC)"
    ls -l ${TBL}.*
    exit $RC 
fi

########################################
# UPLOAD
########################################

sh ./o2g_imp.sh ${TBL}

