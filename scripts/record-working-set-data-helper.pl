#!/usr/bin/perl

# This script sends a SIGINT signal to a running instance of
# record-working-set-data.pl.

use warnings;
use strict;

my @psResult = `ps aux`;
my $pid = "";
my $count = 0;
for my $line (@psResult) {
    if ($line =~ /\/usr\/bin\/perl \.\/record-working-set-data\.pl/) {
        my @lineSplit = split(/\s+/, $line);
        $pid = $lineSplit[1];
        $count++;
    }
}

if ($count == 0) {
    print("Error: no record-working-set-data.pl process found\n");
}
elsif ($count > 1) {
    print("Error: multiple matching processes found\n");
}
else {
    system("kill -s INT $pid\n");
}
