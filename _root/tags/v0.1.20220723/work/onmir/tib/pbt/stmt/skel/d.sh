#!/bin/sh

 SQLCMD=ts
test "x$2" != "x" && SQLCMD=$2

desc.tib $1 $SQLCMD 2>&1 |tee -a d.log 
