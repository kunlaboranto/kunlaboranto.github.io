#!/bin/sh

cmd="/usr/bin/perf stat \
-e alignment-faults \
-e cache-misses -e cache-references \
-e L1-dcache-load-misses -e L1-dcache-load \
-e L1-dcache-store-misses -e L1-dcache-store \
-e LLC-load-misses -e LLC-load \
-e cycles -e stalled-cycles-frontend -e stalled-cycles-backend \
-e bus-cycles \
-e branches -e branch-misses \
-e task-clock -e context-switches -e CPU-migrations -e page-faults \
-e L1-dcache-prefetch-misses -e L1-dcache-prefetch \
-e L1-icache-load-misses -e L1-icache-load \
-e LLC-store-misses -e LLC-store \
-e LLC-prefetch-misses -e LLC-prefetch \
-e dTLB-load-misses -e dTLB-load \
-e dTLB-store-misses -e dTLB-store \
-e iTLB-load-misses -e iTLB-load \
-e branch-load-misses -e branch-load \
-e instructions
-- $1"

opt=" \

<not counted>
    -e L1-icache-prefetch-misses -e L1-icache-prefetch \
    -e dTLB-prefetch-misses -e dTLB-prefetch \
"

echo $cmd
echo $cmd |sh


exit

########################################
# COMMENT

         1,689,760 L1-dcache-load-misses     #    1.820 M/sec                   [71.39%]

         1,711,226 L1-dcache-load-misses     #    0.14% of all L1-dcache hits   [63.11%]
     1,257,405,917 L1-dcache-load            # 1327.522 M/sec                   [62.74%]



latency  [5.89986]
total    [407965220]
latency3 [5.88464]
latency4 [5.88457]

 Performance counter stats for './perf -c -f local_client.conf -i 10000':

         1,711,226 L1-dcache-load-misses     #    0.14% of all L1-dcache hits   [63.11%]
     1,257,405,917 L1-dcache-load            # 1327.522 M/sec                   [62.74%]
        947.183072 task-clock                #    0.314 CPUs utilized
            11,929 context-switches          #    0.013 M/sec
                36 CPU-migrations            #    0.000 M/sec
             4,470 page-faults               #    0.005 M/sec
     3,371,805,450 cycles                    #    3.560 GHz                     [50.37%]
     1,667,130,052 stalled-cycles-frontend   #   49.44% frontend cycles idle    [50.35%]
       935,613,677 stalled-cycles-backend    #   27.75% backend  cycles idle    [50.30%]
     3,653,813,575 instructions              #    1.08  insns per cycle
                                             #    0.46  stalled cycles per insn [62.51%]
       621,905,299 branches                  #  656.584 M/sec                   [62.17%]
           195,042 branch-misses             #    0.03% of all branches         [62.48%]

       3.013961669 seconds time elapsed

########################################
# LIST

    cpu-cycles OR cycles
    stalled-cycles-frontend OR idle-cycles-frontend
    stalled-cycles-backend OR idle-cycles-backend
    instructions
    cache-references
    cache-misses
    branch-instructions OR branches
    branch-misses
bus-cycles

cpu-clock
task-clock
page-faults OR faults
minor-faults
major-faults
context-switches OR cs
cpu-migrations OR migrations
alignment-faults
emulation-faults

L1-dcache-loads
L1-dcache-load-misses
L1-dcache-stores
L1-dcache-store-misses
L1-dcache-prefetches
L1-dcache-prefetch-misses
L1-icache-loads
L1-icache-load-misses
L1-icache-prefetches
L1-icache-prefetch-misses
LLC-loads
LLC-load-misses
LLC-stores
LLC-store-misses
LLC-prefetches
LLC-prefetch-misses
dTLB-loads
dTLB-load-misses
dTLB-stores
dTLB-store-misses
dTLB-prefetches
dTLB-prefetch-misses
iTLB-loads
iTLB-load-misses
branch-loads
branch-load-misses
