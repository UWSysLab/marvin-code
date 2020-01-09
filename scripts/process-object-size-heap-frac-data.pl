#!/usr/bin/perl

# This script takes as input a bunch of files with "histograms," counting the
# fraction of the heap occupied by objects of sizes in the different buckets,
# output by the Marvin instrumentation code. It converts the histograms into
# "CDFs" using histogram-to-cdf.pl and then concatenates all of the CDFs into
# one big file with an extra column holding the app name.

use warnings;
use strict;

my $PREFIX = "data/heapfrac-hist-";
my $SUFFIX = ".txt";

my $OUTPUT = "data/heapfrac-cdf-data.csv";

my @APPS = ("amazon", "candycrush", "googlemaps", "instagram", "pinterest", "spotify", "twitter", "washingtonpost");

print("Size,HeapFrac,AppName\n");

foreach my $app (@APPS) {
    my $fileName = "$PREFIX$app$SUFFIX";
    my @lines = `perl histogram-to-cdf.pl $fileName`;
    foreach my $line (@lines) {
        chomp($line);
        print("$line,$app\n");
    }
}
