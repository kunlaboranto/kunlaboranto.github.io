#!/usr/bin/perl

use strict;
use warnings;
use Time::Local;

my $args = shift || die;
my ($date, $time) = split(' ', $args);
my ($year, $month, $day) = split('/', $date);
my ($hour, $minute, $second) = split(':', $time);

$year = ($year<100 ? ($year<70 ? 2000+$year : 1900+$year) : $year);
print timelocal($second,$minute,$hour,$day,$month-1,$year);  

