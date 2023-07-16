#!/bin/sh

FN="bmt.log"
test "x$1" != "x" && FN="$1"

grep "TPS" "$FN"
echo " Total TPS (Second) = " `grep "TPS" "$FN" | awk 'BEGIN {sum=0;}{sum+=$5} END {print sum}'` "TPS"
