#!/usr/bin/perl

# Generate CSV files containing data for two line graphs: one graph
# plotting the fraction of the heap that is warm over time, and the
# other graph plotting the range scrolled by the user since the last
# heap info log message over time. The times in both CSV files are given
# as offsets from the same starting time, so the two line graphs can be
# plotted on the same x-axis.
#
# This script assumes that the log file given as input has the following
# three kinds of messages:
#
# NIEL scroll: <l> <t> <oldl> <oldt>
# NIEL AbsListView scroll: <deltaY> <incrementalDeltaY>
# NIEL cold object size: <size> large cold object size: <size> large object size: <size> total object size: <size>

use warnings;
use strict;

my $LARGE_INT = 10000000000;

my $usage = "./generate-scrolling-graph.pl log-file";

die $usage unless @ARGV == 1;

my $fileName = shift;

open(FILE, $fileName);
open(WARM_GRAPH_FILE, "> $fileName.graph.warm");
open(SCROLL_GRAPH_FILE, "> $fileName.graph.scroll");

my $curOffset = 0;
my $maxOffset = -$LARGE_INT;
my $minOffset = $LARGE_INT;
my $startHours = -1;
my $startMinutes = -1;
my $startSeconds = -1;
my $startMs = -1;
while(<FILE>) {
    if ($_ =~ /^\d+-\d+\s+(\d+):(\d+):(\d+)\.(\d+)\s+\d+\s+\d+\s+\w+\s+(\S+)\s*:(.+)$/) {
        my $hours = $1;
        my $minutes = $2;
        my $seconds = $3;
        my $ms = $4;
        my $tag = $5;
        my $payload = $6;

        if ($startHours == -1) {
            $startHours = $hours;
            $startMinutes = $minutes;
            $startSeconds = $seconds;
            $startMs = $ms;
        }

        my $curHours = $hours - $startHours;
        my $curMinutes = $minutes - $startMinutes;
        my $curSeconds = $seconds - $startSeconds;
        my $curMs = $ms - $startMs;

        my $timeDiffMs = $curMs + $curSeconds * 1000 + $curMinutes * 60 * 1000 + $curHours * 60 * 60 * 1000;
        my $timeDiffSeconds = $timeDiffMs / 1000;

        if ($payload =~ /NIEL cold object size: (\d+) large cold object size: (\d+) large object size: (\d+) total object size: (\d+)/) {
            my $coldObjectSize = $1;
            my $largeColdObjectSize = $2;
            my $largeObjectSize = $3;
            my $totalObjectSize = $4;

            my $warmFrac = 1 - $coldObjectSize / $totalObjectSize;
            print(WARM_GRAPH_FILE "$timeDiffSeconds,$warmFrac\n");

            my $offsetDiff = $maxOffset - $minOffset;
            if ($offsetDiff < -$LARGE_INT) {
                $offsetDiff = 0;
            }
            print(SCROLL_GRAPH_FILE "$timeDiffSeconds,$offsetDiff\n");

            $curOffset = 0;
            $maxOffset = -$LARGE_INT;
            $minOffset = $LARGE_INT;
        }
        elsif ($payload =~ /NIEL scroll: \d+ (\d+) \d+ (\d+)/) {
            my $t = $1;
            my $oldt = $2;

            my $diff = $t - $oldt;
            $curOffset += $diff;
            if ($curOffset < $minOffset) {
                $minOffset = $curOffset;
            }
            if ($curOffset > $maxOffset) {
                $maxOffset = $curOffset;
            }
        }
        elsif ($payload =~ /NIEL AbsListView scroll: (\S+) (\S+)/) {
            my $deltaY = $1;
            my $incrementalDeltaY = $2;

            $curOffset += $deltaY;
            if ($curOffset < $minOffset) {
                $minOffset = $curOffset;
            }
            if ($curOffset > $maxOffset) {
                $maxOffset = $curOffset;
            }
        }
    }
}

close(FILE);
close(WARM_GRAPH_FILE);
close(SCROLL_GRAPH_FILE);
