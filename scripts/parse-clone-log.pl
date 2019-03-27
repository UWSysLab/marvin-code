#!/usr/bin/perl

# An updated version of parse-microbenchmark-log.pl that only parses the
# messages common to all apps and checks to see if app clones have become
# "inactive" (have not printed a log message within some timeout interval).

use warnings;
use strict;

use lib '.';
use NielAndroidUtils qw(parseLogMessage calcTimeDiffSeconds);

my $INACTIVE_TIMEOUT = 20; # seconds
my $CLONE_NAME = "edu.washington.cs.nl35.memorywaster";

my $startTime = "";
my %pidTimes;

while(<>) {
    my @parsedMessage = parseLogMessage($_);
    if (@parsedMessage > 0) {
        my $time = $parsedMessage[1];
        my $pid = $parsedMessage[2];
        my $msg = $parsedMessage[6];
        if ($startTime eq "") {
            $startTime = $time;
        }
        if ($msg =~ /^Start proc (\d+):$CLONE_NAME(\d+)/) {
            my $startedPid = $1;
            my $cloneNum = $2;
            $pidTimes{$startedPid} = $time;
            print("$time\t$startedPid\t$cloneNum\tstart\n");
        }
        if ($msg =~ /^Process $CLONE_NAME(\d+) \(pid (\d+)\) has died$/) {
            my $cloneNum = $1;
            my $diedPid = $2;
            print("$time\t$diedPid\t$cloneNum\tdie\n");
        }
        if ($msg =~ /^WIN DEATH: Window\{\w+ \w+ $CLONE_NAME(\d+)\/$CLONE_NAME\d+\.MainActivity\}$/) {
            my $cloneNum = $1;
            print("$time\t-\t$cloneNum\twin-death\n");
        }
        if ($msg =~ /^START u0 \{act=android\.intent\.action\.MAIN flg=0x10000000 cmp=$CLONE_NAME(\d+)\/\.MainActivity\} from uid \d+ on display \d+$/) {
            my $cloneNum = $1;
            print("$time\t-\t$cloneNum\tstart-intent\n");
        }
        if (exists $pidTimes{$pid}) {
            $pidTimes{$pid} = $time;
        }

        for my $pid (keys %pidTimes) {
            my $timeDiff = calcTimeDiffSeconds($pidTimes{$pid}, $time);
            if ($timeDiff > $INACTIVE_TIMEOUT) {
                delete($pidTimes{$pid});
                print("$time\t$pid\t-\tinactive\n");
            }
        }
    }
}
