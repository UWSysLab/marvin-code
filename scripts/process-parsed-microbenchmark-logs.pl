#!/usr/bin/perl

# This script expects as input multiple files produced by
# parse-microbenchmark-log.pl.

my $usage = "usage: ./process-parsed-microbenchmark-logs.pl file1 file1-label file2 file2-label ...";
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
        $timeDiff = calcTimeDiffSeconds($startTime, $timestamp);

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
    }
    close(FILE);
    if ($numDeaths != $numWinDeaths) {
        push(@problemFileNames, $fileNames[$i]);
    }
}

print("ERROR: these files had different counts of \"win-death\" and \"die\" events:\n");
for (my $i = 0; $i < @problemFileNames; $i++) {
    print("$problemFileNames[$i]\n");
}

# Copied from parse-gc-collection-working-set-log.pl
sub calcTimeDiffSeconds {
    my ($timeA, $timeB) = @_;
    my ($hourA, $minA, $secA, $msA);
    my ($hourB, $minB, $secB, $msB);
    if ($timeA =~ /^(\d+):(\d+):(\d+)\.(\d+)$/) {
        ($hourA, $minA, $secA, $msA) = ($1, $2, $3, $4);
    }
    else {
        die "Incorrectly formatted time: $timeA";
    }
    if ($timeB =~ /^(\d+):(\d+):(\d+)\.(\d+)$/) {
        ($hourB, $minB, $secB, $msB) = ($1, $2, $3, $4);
    }
    else {
        die "Incorrectly formatted time: $timeB";
    }
    return ($hourB - $hourA) * 60 * 60 + ($minB - $minA) * 60 + ($secB - $secA) + ($msB - $msA) / 1000.0;
}
