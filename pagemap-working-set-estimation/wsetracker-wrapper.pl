#!/usr/bin/perl

use warnings;
use strict;

my $WSETRACKER_ANDROID_DIR = "/data/local/nieltest/";

my $usage = "usage: ./wsetracker-wrapper.pl android?(y/n) pid map-name op";
if (@ARGV < 4) {
    die "$usage\n";
}
my $isAndroid = $ARGV[0];
my $pid = $ARGV[1];
my $mapName = $ARGV[2];
my $action = $ARGV[3];
if (!($isAndroid eq "y" || $isAndroid eq "n")) {
    die "$usage\n";
}

my $catCmd = "cat";
my $wsetrackerCmd = "./wsetracker-x86";
if ($isAndroid eq "y") {
    $catCmd = "adb shell cat";
    $wsetrackerCmd = "adb shell $WSETRACKER_ANDROID_DIR/wsetracker-arm64";
}

my $getMapBoundsOutput = `$catCmd /proc/$pid/maps | ./get-map-bounds.pl`;
my @split = split(/\n/, $getMapBoundsOutput);
for my $line (@split) {
    if ($line =~ /^#/) {
        next;
    }
    my @lineSplit = split(/,/, $line);
    my $curMapName = "NULL";
    if (@lineSplit >= 3) {
        $curMapName = $lineSplit[2];
    }
    my $startAddr = $lineSplit[0];
    my $endAddr = $lineSplit[1];

    if ($curMapName eq $mapName) {
        my $wsetrackerOutput = `$wsetrackerCmd $pid $startAddr $endAddr $action`;
        print("$wsetrackerOutput");
    }
}
