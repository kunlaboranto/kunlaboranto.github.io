#!/bin/sh

DIR="."
test "x$1" != "x" && DIR="$1"

# \ls -1F |xargs du -sk |sort -n -k 1

echo ""
#\ls -1F $DIR |sed -e "s;^;$DIR/;g" |xargs du -sk |sort -n -k 1
\ls -1F $DIR |sed -e "s;^;$DIR/;g" |sed -e 's/^/"/g' |sed -e 's/$/"/g' |xargs -l1 du -sk |sort -n -k 1 |awk '{ printf("%10s %s %s %s %s %s %s %s %s\n", $1, $2, $3, $4, $5, $6, $7, $8, $9); }'

echo "--"
du -sk $DIR |awk '{ printf("%10s %s\n", $1, $2); }'


