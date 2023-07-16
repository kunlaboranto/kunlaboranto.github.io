#!/bin/sh

#run="dstat --nocolor -tpcygrml --float"
#run="dstat --nocolor -tpcygdrml --float --disk-util"
#run="dstat --nocolor -tpcygdrml --float"
#run="dstat --nocolor -tpcygdrmsl --float"
 run="dstat --nocolor -tpcygdrmsnl --float"

LOG="`hostname`_`date '+%y%m%d_%H%M'`.dstat"

#OPT="300 288"
#OPT="30 2880"
 OPT="10 8640"
#OPT="2 43200"

run="${run} ${OPT}"

#if [ -d $HOME/work/onmir/log/. -a "x$1" != "x" ]
if [ -d $HOME/work/onmir/log/. ]
then
    echo "${run} |tee -a $HOME/work/onmir/log/${LOG}"
    ${run} |tee -a $HOME/work/onmir/log/${LOG}
else
    echo "${run} |tee -a ${LOG}"
    ${run} |tee -a ${LOG}
fi

