#!/bin/sh

set -x

find . -type f -size 0 -exec rm -f {} \; -ls 
find . -type f -name "*.orig" -exec rm -f {} \; -ls 
find . -type f -name "*.chksum" -exec rm -f {} \; -ls 

set +x

