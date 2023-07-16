#!/bin/sh

# [CHECK] /etc/sysctl.conf : vm.swappiness = 5

set +x

cat /proc/sys/vm/drop_caches

sync ; sync ; date && free -k
echo 1 > /proc/sys/vm/drop_caches

sync ; sync ; date && free -k
echo 2 > /proc/sys/vm/drop_caches

sync ; sync ; date && free -k
echo 0 > /proc/sys/vm/drop_caches
rc=$?

if [ "x$rc" != "x0" ]
then
    echo "[INFO] rc=$rc"
    sync ; sync ; date && free -k
    echo 1 > /proc/sys/vm/drop_caches
fi

sync ; sync ; date && free -k
cat /proc/sys/vm/drop_caches

set -x
