#!/usr/bin/perl

use warnings;
use strict;

use Math::BigInt;

my $usage = "usage: ./get-map-bounds.pl pid map-name";
if (@ARGV < 2) {
    die "$usage\n";
}
my $pid = $ARGV[0];
my $mapName = $ARGV[1];
print("#start_address\tend_address\tmap_name\n");

my $smapsFileName = "/proc/$pid/smaps";
open(SMAPS_FILE, $smapsFileName);
while (<SMAPS_FILE>) {
    if ($_ =~ /^(\w+)\-(\w+)\s[r\-][w\-][x\-][p\-]\s\w\w\w\w\w\w\w\w\s\d\d:\d\d\s\d+\s+(\S*)$/) {
        my $startAddrHex = $1;
        my $endAddrHex = $2;
        my $curMapName = $3;
        #print("$1 $2 $3\n");
        #my $startAddr = hex($startAddrHex);
        #my $endAddr = hex($endAddrHex);
        my $startAddr = Math::BigInt->from_hex($startAddrHex);
        my $endAddr = Math::BigInt->from_hex($endAddrHex);
        print("$startAddr\t$endAddr\t$curMapName\n");
    }
}
close(SMAPS_FILE);
