
echo 1

 PGWAL="xx"
#PGWAL=""
#a.sh: line 5: PGWAL: parameter null or not set
#V1=${PGWAL?}
 V1=${PGWAL:?}

echo 2
echo $V1
echo 2
