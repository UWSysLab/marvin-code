#!/usr/bin/perl

use warnings;
use strict;

my $MICROBENCHMARK_NAME = "edu.washington.cs.nl35.microbenchmark";

print("timestamp\tpid\tclone\tevent\n");
while(<>) {
    if (/^(\d+)-(\d+)\s+(\d+):(\d+):(\d+)\.(\d+)\s+(\d+)\s+(\d+)\s+(\w+)\s+(\w+)\s*:\s*(.*)$/) {
        my ($month, $date, $hours, $minutes, $seconds, $milliseconds) = ($1, $2, $3, $4, $5, $6);
        my ($pid, $tid) = ($7, $8);
        my ($logLevel, $tag, $msg) = ($9, $10, $11);
        my $time = "$hours:$minutes:$seconds.$milliseconds";
        if ($msg =~ /^Start proc (\d+):$MICROBENCHMARK_NAME(\d+)/) {
            my $startedPid = $1;
            my $cloneNum = $2;
            print("$time\t$startedPid\t$cloneNum\tstart\n");
        }
        if ($msg =~ /^MicroBenchmark onResume finished$/) {
            print("$time\t$pid\tN/A\tresume\n");
        }
        if ($msg =~ /^Process $MICROBENCHMARK_NAME(\d+) \(pid (\d+)\) has died$/) {
            my $cloneNum = $1;
            my $diedPid = $2;
            print("$time\t$diedPid\t$cloneNum\tdie\n");
        }
        if ($msg =~ /^START u0 \{act=android\.intent\.action\.MAIN flg=0x10000000 cmp=$MICROBENCHMARK_NAME(\d+)\/\.MainActivity\} from uid \d+ on display \d+$/) {
            my $cloneNum = $1;
            print("$time\tN/A\t$cloneNum\tstart-intent\n");
        }
    }
}
