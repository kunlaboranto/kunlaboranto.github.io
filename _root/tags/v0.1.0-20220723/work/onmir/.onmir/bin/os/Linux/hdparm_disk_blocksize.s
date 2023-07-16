#!/bin/sh

for i in `ls /dev/sd?`
do
    echo $i
    sudo hdparm -I $i |grep -e "Model " -e "Sector "
done

