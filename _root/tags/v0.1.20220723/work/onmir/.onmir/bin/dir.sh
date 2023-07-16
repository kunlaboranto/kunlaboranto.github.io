#!/bin/sh

\ls -l $1 | awk '{ cnt = cnt + 1}{sum = sum + $5} {printf( "%s %2d %s \t %s \t %15.0lf  %6.6s  %4.4s  %5.5s  %s\n",$1, $2, $3, $4,$5,$6,$7,$8, $9)} END{printf("\n....ToTal File Count : %d EA [%.3lf MB]\n\n", cnt, sum/1024/1024)}'
