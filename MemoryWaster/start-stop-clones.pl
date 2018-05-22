#!/usr/bin/perl

use warnings;
use strict;

my $usage = "./start-stop-clones.pl [start|stop] num-clones";
die $usage unless @ARGV == 2;

my $cmd = shift;
my $numClones = shift;
if (!($cmd =~ /^start|stop$/)) {
    die $usage;
}

for (my $i = 0; $i < $numClones; $i++) {
    if ($cmd eq "start") {
        system("adb shell am start -a android.intent.action.MAIN -n edu.washington.cs.nl35.memorywaster$i/.MainActivity");
    }
    elsif ($cmd eq "stop") {
        system("adb shell am force-stop edu.washington.cs.nl35.memorywaster$i");
    }
}
