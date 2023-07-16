#!/bin/sh

echo "USER_=[$USER_]"
echo "PASS_=[$PASS_]"
echo "TRUNCATE_=[$TRUNCATE_]"

test "x" == "x$USER_" && USER_=test
test "x" == "x$PASS_" && PASS_=test
test "x" == "x$TRUNCATE_" && TRUNCATE_=N

MODE="--import"
#MODE="--export"

# OPT="--dsn GOLDILOCKS"
# OPT=$OPT" --commit 5000"
# OPT=$OPT" --array 1000"
# OPT=$OPT" --atomic"
# OPT=$OPT" --parallel 4"
# OPT=$OPT" --errors 200"
# OPT=""                      # reset
OPT=$OPT" --no-copyright"
#OPT=$OPT" --silent"

if [ "x" != "x$1" ]
then
    TBL=$1
else
    echo "Usage] sh $0 <table_name>"
    exit -1
fi 

########################################
# FUNC
########################################

OPT2=$OPT2" --no-prompt"

function doTrunc
{
    gsqlnet $USER_ $PASS_ ${OPT2} << EOF
truncate table $TBL ;
commit;
EOF

}

function doSel
{
gsqlnet $USER_ $PASS_ ${OPT2} << EOF
SELECT * FROM $TBL LIMIT 10 ;
EOF
}


########################################
# MAIN
########################################

if [ ! -f ${TBL}.ctl ]
then
    sed -e "s/__TB_SKEL__/${TBL}/g" skel.ctl > ${TBL}.ctl
fi

# if want , TRUNCATE table before operation.
if [ "x$TRUNCATE_" == "xY" -o "x$TRUNCATE_" == "xy" ]
then
    doTrunc 
fi

# Show Before Data
doSel

set -x
time gloadernet $USER_ $PASS_ $MODE -c ${TBL}.ctl -d ${TBL}.dat -l ${TBL}.log -b ${TBL}.bad ${OPT}
RC=$?
set +x

if [ $RC != 0 ]
then
    echo "[ERROR] ${TBL} upload fail. ($RC)"
    ls -l ${TBL}.*
    exit $RC
fi

# Show Uploaded Data
doSel

mkdir -p ${TBL}
mv ${TBL}.* ${TBL}/.

exit 0
