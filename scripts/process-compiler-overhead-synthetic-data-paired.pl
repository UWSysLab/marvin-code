#!/usr/bin/perl

# The point of this script is to consider the ith round time of Android for a
# particular configuration and the ith round time of Marvin for a particular
# configuration as a pair and compute individual overhead values for each pair,
# and then take the mean and standard deviation of those individual overhead
# values.

use warnings;
use strict;

use Math::NumberCruncher;

my $SKIP_NUM = 5; # Skip the first X entries
my $COUNT_NUM = 40; # Calculate average over the next X entries

my $usage = "usage: ./process-compiler-overhead-synthetic-data-paired.pl marvin-file android-file";
die "$usage\n" unless @ARGV == 2;

my ($file1, $file2) = @ARGV;
open(FILE1, $file1);

my @times1 = ();
my $counter1 = 0;
while(<FILE1>) {
    if ($_ =~ /Worker thread performed 100000 iterations in (\d+) ms/) {
        if ($counter1 >= $SKIP_NUM && $counter1 < $SKIP_NUM + $COUNT_NUM) {
            push(@times1, $1);
        }
        $counter1++;
    }
}
close(FILE1);

my @times2 = ();
my $counter2 = 0;
open(FILE2, $file2);
while(<FILE2>) {
    if ($_ =~ /Worker thread performed 100000 iterations in (\d+) ms/) {
        if ($counter2 >= $SKIP_NUM && $counter2 < $SKIP_NUM + $COUNT_NUM) {
            push(@times2, $1);
        }
        $counter2++;
    }
}
close(FILE2);

if (scalar(@times1) != scalar(@times2)) {
    die "Error: data count mismatch\n";
}

my @overheads = ();
for (my $i = 0; $i < @times1; $i++) {
    push(@overheads, $times1[$i] / $times2[$i]);
}
my $len = @overheads;
my $mean = Math::NumberCruncher::Mean(\@overheads);
my $stddev = Math::NumberCruncher::StandardDeviation(\@overheads);
print("Num entries: $len\n");
print("Mean: $mean\n");
print("Standard deviation: $stddev\n");
