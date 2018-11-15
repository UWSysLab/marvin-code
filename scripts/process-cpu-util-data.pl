#!/usr/bin/perl

# Feed this script the output from running vmstat in an adb shell.

use warnings;
use strict;

use Math::NumberCruncher;

my $SKIP_NUM = 3; # Skip the first X entries
my $COUNT_NUM = 10; # Calculate average over the next X entries

my @idleVals = ();
my $counter = 0;
while(<>) {
    if ($_ =~ /^\s+(\d+\s+){14}(\d+\s+)/) {
        if ($counter >= $SKIP_NUM && $counter < $SKIP_NUM + $COUNT_NUM) {
            push(@idleVals, $2);
        }
        $counter++;
    }
}

my $len = @idleVals;
my $mean = Math::NumberCruncher::Mean(\@idleVals);
my $stddev = Math::NumberCruncher::StandardDeviation(\@idleVals);

print("Num entries: $len\n");
print("Mean: $mean\n");
print("Standard deviation: $stddev\n");
