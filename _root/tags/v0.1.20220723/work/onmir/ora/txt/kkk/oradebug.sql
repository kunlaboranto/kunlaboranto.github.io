set time on;

oradebug setospid 1234
oradebug unlimit
oradebug event 10046 trace name context forever, level 8
!sleep 2
--!sleep 10
oradebug tracefile_name
oradebug event 10046 trace name context off
oradebug close_trace

