#!/usr/bin/perl

# This script is an updated version of process-parsed-microbenchmark-logs.pl
# that counts "active" rather than "live" apps. It expects as input multiple
# files produced by parse-allocatoractivity-log.pl.

use warnings;
use strict;

use lib '.';
use NielAndroidUtils qw(calcTimeDiffSeconds);

my $usage = "usage: ./process-parsed-allocatoractivity-logs.pl file1 file1-label file2 file2-label ...";
if (@ARGV < 2 || @ARGV % 2 != 0) {
    die "$usage\n";
}

my @fileNames;
my @labels;
for (my $i = 0; $i < @ARGV; $i += 2) {
    push(@fileNames, $ARGV[$i]);
    push(@labels, $ARGV[$i + 1]);
}

my @problemFileNames;

print("Time,NumLiveApps,Label\n");
for (my $i = 0; $i < @fileNames; $i++) {
    my $label = $labels[$i];
    my $numLiveApps = 0;
    my $startTime;
    my $numDeaths = 0;
    my $numWinDeaths = 0;
    open(FILE, $fileNames[$i]);
    while(<FILE>) {
        if ($_ =~ /^timestamp\s+pid\s+clone\s+event$/) {
            next;
        }

        my @lineSplit = split(/\s+/, $_);
        my $timestamp = $lineSplit[0];
        my $event = $lineSplit[3];

        if (!defined($startTime)) {
            $startTime = $timestamp;
        }
        my $timeDiff = calcTimeDiffSeconds($startTime, $timestamp);
        if ($timeDiff < 0) {
            $timeDiff = $timeDiff + 24*60*60;
        }

        if ($event eq "start") {
            $numLiveApps++;
            print("$timeDiff,$numLiveApps,$label\n");
        }
        elsif ($event eq "die") {
            $numLiveApps--;
            $numDeaths++;
            print("$timeDiff,$numLiveApps,$label\n");
        }
        elsif ($event eq "win-death") {
            $numWinDeaths++;
        }
        elsif ($event eq "inactive") {
            $numLiveApps--;
            print("$timeDiff,$numLiveApps,$label\n");
        }
        elsif ($event eq "active") {
            $numLiveApps++;
            print("$timeDiff,$numLiveApps,$label\n");
        }
    }
    close(FILE);
    if ($numDeaths != $numWinDeaths) {
        push(@problemFileNames, $fileNames[$i]);
    }
}

if (@problemFileNames > 0) {
    print(STDERR "ERROR: these files had different counts of \"win-death\" and \"die\" events:\n");
    for (my $i = 0; $i < @problemFileNames; $i++) {
        print(STDERR "$problemFileNames[$i]\n");
    }
}
