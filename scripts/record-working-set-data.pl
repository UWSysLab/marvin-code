#!/usr/bin/perl

# This script streamlines the process of collecting working set data from an
# app under multiple conditions. The user annotates changes in the experimental
# conditions by sending a SIGINT signal to this script, making it easy to
# perform that annotation with a single button press.

use warnings;
use strict;

use sigtrap 'handler', \&signalHandler, 'INT';

use lib '.';
use NielAndroidUtils qw(parseLogMessage calcTimeDiffSeconds);

my $startTime = "";
my $signalCounter = 0;
while(<>) {
    my @parsedMessage = parseLogMessage($_);
    if (@parsedMessage > 0) {
        if ($startTime eq "") {
            $startTime = $parsedMessage[1];
        }
        my $time = $parsedMessage[1];
        my $msg = $parsedMessage[6];
        my $timeDiff = calcTimeDiffSeconds($startTime, $time);
        if ($msg =~ /read working set size: (\d+)/) {
            my $readWorkingSet = $1;
            print("$timeDiff,$readWorkingSet,READ\n");
        }
        elsif ($msg =~ /write working set size: (\d+)/) {
            my $writeWorkingSet = $1;
            print("$timeDiff,$writeWorkingSet,WRITE\n");
        }
    }
}

sub signalHandler {
    $signalCounter += 1;
    my $message = "";
    if ($signalCounter == 1) {
        $message = "Idle foreground";
    }
    elsif ($signalCounter == 2) {
        $message = "Background";
    }
    elsif ($signalCounter >= 3) {
        $message = "Done collecting data";
    }

    print("========== $message ==========\n");
}
