#!/usr/bin/perl

# Convert a scaled histogram outputted from my ART instrumentation code
# into (x,y) CDF points.

use warnings;
use strict;

my $usage = "./histogram-to-cdf.pl histogram-file";
die $usage unless @ARGV==1;

my $filename = shift;

my $sumProbMass = 0;
open(FILE, $filename);
while(<FILE>) {
    if ($_ =~ /\[\S+,(\S+)\):\s+(\S+)/) {
        my $xVal = $1;
        my $probMass = $2;
        $sumProbMass += $probMass;
        print("$xVal,$sumProbMass\n");
    }
}
