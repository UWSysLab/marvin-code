#!/usr/bin/perl

use warnings;
use strict;

use lib '.';
use NielAndroidUtils qw(parseLogMessage);

my $MICROBENCHMARK_NAME = "edu.washington.cs.nl35.microbenchmark";

print("timestamp\tpid\tclone\tevent\n");
while(<>) {
    my @parsedMessage = parseLogMessage($_);
    if (@parsedMessage > 0) {
        my $time = $parsedMessage[1];
        my $pid = $parsedMessage[2];
        my $msg = $parsedMessage[6];
        if ($msg =~ /^Start proc (\d+):$MICROBENCHMARK_NAME(\d+)/) {
            my $startedPid = $1;
            my $cloneNum = $2;
            print("$time\t$startedPid\t$cloneNum\tstart\n");
        }
        if ($msg =~ /^$MICROBENCHMARK_NAME(\d+) onResume finished$/) {
            my $cloneNum = $1;
            print("$time\t$pid\t$cloneNum\tresume\n");
        }
        if ($msg =~ /^Process $MICROBENCHMARK_NAME(\d+) \(pid (\d+)\) has died$/) {
            my $cloneNum = $1;
            my $diedPid = $2;
            print("$time\t$diedPid\t$cloneNum\tdie\n");
        }
        if ($msg =~ /^WIN DEATH: Window\{\w+ \w+ $MICROBENCHMARK_NAME(\d+)\/$MICROBENCHMARK_NAME\d+\.MainActivity\}$/) {
            my $cloneNum = $1;
            print("$time\t-\t$cloneNum\twin-death\n");
        }
        if ($msg =~ /^START u0 \{act=android\.intent\.action\.MAIN flg=0x10000000 cmp=$MICROBENCHMARK_NAME(\d+)\/\.MainActivity\} from uid \d+ on display \d+$/) {
            my $cloneNum = $1;
            print("$time\t-\t$cloneNum\tstart-intent\n");
        }
        if ($msg =~ /^$MICROBENCHMARK_NAME(\d+) finished loading working set$/) {
            my $cloneNum = $1;
            print("$time\t$pid\t$cloneNum\tloaded-working-set\n");
        }
        if ($msg =~ /^$MICROBENCHMARK_NAME(\d+) finished loading all arrays$/) {
            my $cloneNum = $1;
            print("$time\t$pid\t$cloneNum\tloaded-all\n");
        }
    }
}
