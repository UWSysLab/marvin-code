#!/usr/bin/perl

use warnings;
use strict;

my $MICROBENCHMARK_NAME = "edu.washington.cs.nl35.microbenchmark";

while(<>) {
    if (/^(\d+)-(\d+)\s+(\d+):(\d+):(\d+)\.(\d+)\s+(\d+)\s+(\d+)\s+(\w+)\s+(\w+)\s*:\s*(.*)$/) {
        my ($month, $date, $hours, $minutes, $seconds, $milliseconds) = ($1, $2, $3, $4, $5, $6);
        my ($pid, $tid) = ($7, $8);
        my ($logLevel, $tag, $msg) = ($9, $10, $11);
        if ($msg =~ /^Start proc (\d+):$MICROBENCHMARK_NAME/) {
            my $startedPid = $1;
            print("Started microbenchmark process $startedPid at time $milliseconds\n");
        }
        if ($msg =~ /^onResume finished$/) {
            print("Microbenchmark process $pid resumed at time $milliseconds\n");
        }
    }
}
