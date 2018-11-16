#!/usr/bin/perl

# Feed this script the output of strace.

use warnings;
use strict;

my $readBytes = 0;
my $preadBytes = 0;
my $pread64Bytes = 0;
while(<>) {
    if ($_ =~ /^\d+\s+<\.\.\. read resumed>.*\s+=\s+(\d+)$/) {
        $readBytes += $1;
    }
    elsif ($_ =~ /^\d+\s+read\(.*\)\s+=\s+(\d+)$/) {
        $readBytes += $1;
    }
    elsif ($_ =~ /^\d+\s+<\.\.\. pread resumed>.*\s+=\s+(\d+)$/) {
        $preadBytes += $1;
    }
    elsif ($_ =~ /^\d+\s+pread\(.*\)\s+=\s+(\d+)$/) {
        $preadBytes += $1;
    }
    elsif ($_ =~ /^\d+\s+<\.\.\. pread64 resumed>.*\s+=\s+(\d+)$/) {
        $pread64Bytes += $1;
    }
    elsif ($_ =~ /^\d+\s+pread64\(.*\)\s+=\s+(\d+)$/) {
        $pread64Bytes += $1;
    }
    elsif ($_ =~ /read/) {
        print("Did not match this line: $_");
    }
}

my $totalBytes = $readBytes + $preadBytes + $pread64Bytes;

print("Total bytes read: $totalBytes\n");
print("read: $readBytes\n");
print("pread: $preadBytes\n");
print("pread64: $pread64Bytes\n");
