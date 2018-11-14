#!/usr/bin/perl

# Feed this script the log output produced by MicroBenchmark's worker thread.

use warnings;
use strict;

use Math::NumberCruncher;

my $SKIP_NUM = 5; # Skip the first X entries
my $COUNT_NUM = 40; # Calculate average over the next X entries

my @times = ();
my $counter = 0;
while(<>) {
    if ($_ =~ /Worker thread performed 100000 iterations in (\d+) ms/) {
        if ($counter >= $SKIP_NUM && $counter < $SKIP_NUM + $COUNT_NUM) {
            push(@times, $1);
        }
        $counter++;
    }
}

my $len = @times;
my $mean = Math::NumberCruncher::Mean(\@times);
my $stddev = Math::NumberCruncher::StandardDeviation(\@times);

print("Num entries: $len\n");
print("Mean: $mean\n");
print("Standard deviation: $stddev\n");
