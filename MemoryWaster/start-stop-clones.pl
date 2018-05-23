#!/usr/bin/perl

use warnings;
use strict;

my $PARENT_PACKAGE = "edu.washington.cs.nl35";

my $usage = "./start-stop-clones.pl [start|stop] app-name num-clones";
die $usage unless @ARGV == 3;

my $cmd = shift;
my $appName = shift;
my $numClones = shift;
if (!($cmd =~ /^start|stop$/)) {
    die $usage;
}

my $packageName = lc $appName;

for (my $i = 0; $i < $numClones; $i++) {
    if ($cmd eq "start") {
        system("adb shell am start -a android.intent.action.MAIN -n $PARENT_PACKAGE.$packageName$i/.MainActivity");
    }
    elsif ($cmd eq "stop") {
        system("adb shell am force-stop $PARENT_PACKAGE.$packageName$i");
    }
}
