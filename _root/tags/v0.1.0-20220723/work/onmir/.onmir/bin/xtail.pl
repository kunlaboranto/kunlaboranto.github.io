#!/usr/bin/perl

# Usage:
# cat <file_name> | perl -0pe 's/(\[2018.*)\n(.*)\n/$1 $2\n/g'
#

$log_file = 'altibase_boot.log' ;

if ($#ARGV >= 0) { $log_file = $ARGV[0] ; }
if ($#ARGV >= 1) { $tail_pos = $ARGV[1] ; }


# use strict;
# use warnings;
use Time::HiRes qw(usleep nanosleep);

# CRETED DATE(YYYYMMDD)
# my @date = localtime(time) ;
# my $today = sprintf("%04d%02d%02d", $date[5] + 1900, $date[4] + 1, $date[3]);
# my $log_file = '/estenpark/log/'.$today.'/data.log';

#open(my $FILE, '<',  $log_file) || die $!;
open FILE,"< $log_file" || die $!;

print ">> Tail (Perl) Start .. ( '$log_file' )\n" ;

# TODO: 뒤에서 특정라인위치로 이동하는 방법요
seek FILE,-1, 2;  #get past last eol 

$ix = 0 ;
$hit= 0 ;
for (;;) 
{
    for ($curpos = tell(FILE); $_ = <FILE>;
       $curpos = tell(FILE)) 
    {

        ## do something exciting here

        $ix ++ ;

        #if ( m/(\[2018.*)/ )
        if ( m/(\[20[0-9][0-9]\/[01].*)/ )
        {
            #$line = $_ ; $line =~ s/(\[2018.*)\n/$1/ ;
            $line = $_ ; $line =~ s/(\[20[0-9][0-9]\/[01].*)\n/$1/ ;

            $hit = 1 ;
            # print "\n!! HIT !!\nLINE=[$_]\n" ;
            # print "\n!! HIT !!\nLINE=[$line]\n" ;
        }
        else
        {
            if ( $hit )
            {
                $hit = 0 ;
                print "$line $_" ;
                $line = "" ;
            }
            else
            {
                print $_ ;
            }
        }

        # sleep(1);
        # [NOTE] add for unlimited process fork
        # select(undef, undef, undef, 0.1);
    }

    # sleep(1);
    select(undef, undef, undef, 0.1);
    seek(FILE, $curpos, 0);
}


