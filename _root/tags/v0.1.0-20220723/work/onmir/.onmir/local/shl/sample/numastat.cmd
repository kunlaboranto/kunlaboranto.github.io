#!/bin/bash


numastat

echo ">> use "-p <pid>" for more detail"


exit

$ numastat -p 2039
[2014/02/16 41:13:48] (numastat)
                           node0           node1
numa_hit               858536561      1637177277
numa_miss                9874197               0
numa_foreign                   0         9874197
interleave_hit             69747           67635
local_node             853971007      1636712851
other_node              14439751          464426


$ sudo numastat -p 2039
[sudo] password for paul: 

Per-node process memory usage (in MBs) for PID 2039 (sshd)
                           Node 0           Total
                  --------------- ---------------
Huge                         0.00            0.00
Heap                         0.05            0.05
Stack                        0.02            0.02
Private                      1.14            1.14
----------------  --------------- ---------------
Total                        1.21            1.21

