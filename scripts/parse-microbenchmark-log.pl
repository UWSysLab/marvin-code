#!/usr/bin/perl

use warnings;
use strict;

my $MICROBENCHMARK_NAME = "edu.washington.cs.nl35.microbenchmark";

while(<>) {
    if (/^(\d+)-(\d+)\s+(\d+):(\d+):(\d+)\.(\d+)\s+(\d+)\s+(\d+)\s+(\w+)\s+(\w+)\s*:\s*(.*)$/) {
        my ($month, $date, $hours, $minutes, $seconds, $milliseconds) = ($1, $2, $3, $4, $5, $6);
        my ($pid, $tid) = ($7, $8);
        my ($logLevel, $tag, $msg) = ($9, $10, $11);
        my $time = "$hours:$minutes:$seconds.$milliseconds";
        if ($msg =~ /^Start proc (\d+):$MICROBENCHMARK_NAME\d+/) {
            my $startedPid = $1;
            print("$time\t$startedPid\tstart\n");
        }
        if ($msg =~ /^MicroBenchmark onResume finished$/) {
            print("$time\t$pid\tresume\n");
        }
        if ($msg =~ /^Process $MICROBENCHMARK_NAME\d+ \(pid (\d+)\) has died$/) {
            my $diedPid = $1;
            print("$time\t$diedPid\tdie\n");
        }
    }
}
