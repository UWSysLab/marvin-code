#!/usr/bin/perl

use warnings;
use strict;

my $usage = "usage: ./wsetracker-wrapper.pl pid map-name op";
if (@ARGV < 3) {
    die "$usage\n";
}
my $pid = $ARGV[0];
my $mapName = $ARGV[1];
my $action = $ARGV[2];

my $getMapBoundsOutput = `./get-map-bounds.pl $pid`;
my @split = split(/\n/, $getMapBoundsOutput);
for my $line (@split) {
    if ($line =~ /^#/) {
        next;
    }
    my @lineSplit = split(/\s+/, $line);
    my $curMapName = "NULL";
    if (@lineSplit >= 3) {
        $curMapName = $lineSplit[2];
    }
    my $startAddr = $lineSplit[0];
    my $endAddr = $lineSplit[1];

    if ($curMapName eq $mapName) {
        my $wsetrackerOutput = `./wsetracker-x86 $pid $startAddr $endAddr $action`;
        print("$wsetrackerOutput");
    }
}
