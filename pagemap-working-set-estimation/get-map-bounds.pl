#!/usr/bin/perl

# Get the start and end addresses (as decimal numbers) and names of each
# mapping in /proc/[pid]/maps or /proc/[pid]/smaps.

use warnings;
use strict;

use Math::BigInt;

print("#start_address,end_address,map_name\n");
while (<>) {
    if ($_ =~ /^(\w+)\-(\w+)\s[r\-][w\-][x\-][p\-]\s\w\w\w\w\w\w\w\w\s\d\d:\d\d\s\d+\s+(.*)$/) {
        my $startAddrHex = $1;
        my $endAddrHex = $2;
        my $curMapName = $3;
        my $startAddr = Math::BigInt->from_hex($startAddrHex);
        my $endAddr = Math::BigInt->from_hex($endAddrHex);
        print("$startAddr,$endAddr,$curMapName\n");
    }
}
