#!/bin/sh

\rm -f _login.sql
\mv login.sql _login.sql

SQLCMD=.is2
test "x$2" != "x" && SQLCMD=$2

desc.alt $1 $SQLCMD 2>&1 |tee -a d.log 

\mv _login.sql login.sql
