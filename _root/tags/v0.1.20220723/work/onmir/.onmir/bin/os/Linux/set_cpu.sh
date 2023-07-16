#!/bin/sh

for i in $(ps -eLf |awk '{print $4}') ; do echo "taskset -cp 0 $i" ; done;
#for i in $(ps -eLf |awk '{print $4}') ; do taskset -cp 0 $i ; done;

exit 0

#for i in $(ps aux |awk '{print $2}') ; do echo "taskset -p 0x00000001 $i" ; done;
#for i in $(ps aux |awk '{print $2}') ; do taskset -p 0x00000001 $i ; done;
#for i in $(ps aux |awk '{print $2}') ; do taskset -p 0xFFFFFFFF $i ; done;

for i in $(ps aux |grep $USER |awk '{print $2}') ; do echo "taskset -p 0xFFFFFFFF $i" ; done;
for i in $(ps aux |grep $USER |awk '{print $2}') ; do taskset -p 0xFFFFFFFF $i ; done;

