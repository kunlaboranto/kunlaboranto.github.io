#!/bin/sh

CAT8="expand -t 8"

run=""
function doRun
{
    
    echo ${run} |sh

    echo ">> [DONE] ${run}"
    echo ">> "
    echo ">> "
}

SRC="1.sql"
test "x"$1 == "x" || SRC=$1

# set -x

run="sdiff -w 240 ${SRC} 1.sql "
doRun |${CAT8} |grep -n ^ |sed -e 's/^[0-9][0-9][0-9]:/ &/g' |sed -e 's/^[0-9][0-9]:/  &/g' |sed -e 's/^[0-9]:/   &/g' |grep -e '>> ' -e ' | ' -e ' <$' -e '            > ' 

run="sdiff -w 240 ${SRC} 2.sql "
doRun |${CAT8} |grep -n ^ |sed -e 's/^[0-9][0-9][0-9]:/ &/g' |sed -e 's/^[0-9][0-9]:/  &/g' |sed -e 's/^[0-9]:/   &/g' |grep -e '>> ' -e ' | ' -e ' <$' -e '            > ' 

run="sdiff -w 240 ${SRC} 5.sql "
doRun |${CAT8} |grep -n ^ |sed -e 's/^[0-9][0-9][0-9]:/ &/g' |sed -e 's/^[0-9][0-9]:/  &/g' |sed -e 's/^[0-9]:/   &/g' |grep -e '>> ' -e ' | ' -e ' <$' -e '            > ' 

run="sdiff -w 240 ${SRC} 9.sql "
doRun |${CAT8} |grep -n ^ |sed -e 's/^[0-9][0-9][0-9]:/ &/g' |sed -e 's/^[0-9][0-9]:/  &/g' |sed -e 's/^[0-9]:/   &/g' |grep -e '>> ' -e ' | ' -e ' <$' -e '            > ' 



# set +x

