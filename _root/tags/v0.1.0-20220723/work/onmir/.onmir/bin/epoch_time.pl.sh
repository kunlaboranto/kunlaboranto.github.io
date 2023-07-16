#!/bin/sh

function f_epoch_time
{
    echo "\
#!/usr/bin/perl

use strict;
use warnings;
use Time::Local;

my \$args = shift || die;
my (\$date, \$time) = split(' ', \$args);
my (\$year, \$month, \$day) = split('/', \$date);
my (\$hour, \$minute, \$second) = split(':', \$time);

\$year = (\$year<100 ? (\$year<70 ? 2000+\$year : 1900+\$year) : \$year);
print timelocal(\$second,\$minute,\$hour,\$day,\$month-1,\$year);  
" \
> /tmp/$LOGNAME/_epoch_time.pl

perl /tmp/$LOGNAME/_epoch_time.pl "$*"

}

####################
# MAIN
####################

mkdir -p /tmp/$LOGNAME

RC=`f_epoch_time "1970/01/01 19:00:00"`
echo "$RC"

exit 0
