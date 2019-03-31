#!/usr/bin/perl

# An updated version of parse-microbenchmark-log.pl that is tailored to the
# MemoryWaster AllocatorActivity and observes when app clones become "inactive"
# and "active." Intuitively, an app clone is considered inactive if it becomes
# too slow to perform work or print log messages reflecting that work. Here,
# an AllocatorActivity clone is considered inactive if it has not performed
# bucket deletion within a given timeout interval, and the app clone is
# considered active once again if it performs bucket deletion within a
# (possibly smaller) "active threshold" interval. Active/inactive detection
# relies on the AllocatorActivity performing bucket deletion at some regular
# interval.

use warnings;
use strict;

use lib '.';
use NielAndroidUtils qw(parseLogMessage calcTimeDiffSeconds);

my $STATUS_ACTIVE = 0;
my $STATUS_INACTIVE = 1;
my $STATUS_DEAD = 2;

my $INACTIVE_TIMEOUT = 20; # seconds
my $ACTIVE_THRESHOLD = 7; # seconds
my $CLONE_NAME = "edu.washington.cs.nl35.memorywaster";

my $startTime = "";
my %pidTimes;
my %pidStatuses;

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
            $pidStatuses{$startedPid} = $STATUS_ACTIVE;
            print("$time\t$startedPid\t$cloneNum\tstart\n");
        }
        if ($msg =~ /^Process $CLONE_NAME(\d+) \(pid (\d+)\) has died$/) {
            my $cloneNum = $1;
            my $diedPid = $2;
            $pidStatuses{$diedPid} = $STATUS_DEAD;
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
        if ($msg =~ /^Deleted \d+ buckets starting at \d+ with stride \d+$/) {
            if (!exists($pidTimes{$pid})) {
                print(STDERR "ERROR: startup of clone with PID $pid was not recorded\n");
            }

            # Check if this process has become active
            my $timeDiff = calcTimeDiffSeconds($pidTimes{$pid}, $time);
            if ($timeDiff < $ACTIVE_THRESHOLD && $pidStatuses{$pid} == $STATUS_INACTIVE) {
                $pidStatuses{$pid} = $STATUS_ACTIVE;
                print("$time\t$pid\t-\tactive\n");
            }

            $pidTimes{$pid} = $time;
        }

        # Check if any processes have become inactive
        for my $pid (keys %pidTimes) {
            my $timeDiff = calcTimeDiffSeconds($pidTimes{$pid}, $time);
            if ($timeDiff >= $INACTIVE_TIMEOUT && $pidStatuses{$pid} == $STATUS_ACTIVE) {
                $pidStatuses{$pid} = $STATUS_INACTIVE;
                print("$time\t$pid\t-\tinactive\n");
            }
        }
    }
}
