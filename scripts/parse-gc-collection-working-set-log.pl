#!/usr/bin/perl

use warnings;
use strict;

my $usage = "./parse-gc-collection-working-set-log.pl inputFile outputPrefix";
die $usage unless @ARGV == 2;

my ($inputFile, $outputPrefix) = @ARGV;

my $readWsFile = "$outputPrefix-read-working-set.txt";
my $writeWsFile = "$outputPrefix-write-working-set.txt";
my $gcFile = "$outputPrefix-gc-collection.txt";

open(INPUT_FILE, $inputFile);
open(READ_WS_FILE, "> $readWsFile");
open(WRITE_WS_FILE, "> $writeWsFile");
open(GC_FILE, "> $gcFile");

print(READ_WS_FILE "#seconds\tbytes\n");
print(WRITE_WS_FILE "#seconds\tbytes\n");
print(GC_FILE "#seconds\tbytes\n");

my $startTime = "";

while(<INPUT_FILE>) {
    if (/^(\d+)-(\d+)\s+(\d+):(\d+):(\d+)\.(\d+)\s+(\d+)\s+(\d+)\s+(\w+)\s+(\w+)\s*:\s*(.*)$/) {
        my ($month, $date, $hours, $minutes, $seconds, $milliseconds) = ($1, $2, $3, $4, $5, $6);
        my ($pid, $tid) = ($7, $8);
        my ($logLevel, $tag, $msg) = ($9, $10, $11);
        my $time = "$hours:$minutes:$seconds.$milliseconds";
        if ($startTime eq "") {
            $startTime = $time;
        }
        my $elapsedSeconds = calcTimeDiffSeconds($startTime, $time);
        if ($msg =~ /^NIEL read working set size: (\d+)$/) {
            my $size = $1;
            print(READ_WS_FILE "$elapsedSeconds\t$size\n");
        }
        if ($msg =~ /^NIEL write working set size: (\d+)$/) {
            my $size = $1;
            print(WRITE_WS_FILE "$elapsedSeconds\t$size\n");
        }
        if ($msg =~ /^(.+) GC freed \d+\((\S+)\) AllocSpace objects, \d+\((\S+)\) LOS objects, \d+% free, \S+\/\S+, paused \S+ms total \S+ms$/) {
            my $gcType = $1;
            my $allocSpaceFreed = $2;
            my $losFreed = $3;
            my $allocSpaceFreedBytes = getBytes($allocSpaceFreed);
            my $losFreedBytes = getBytes($losFreed);
            my $totalFreedBytes = $allocSpaceFreedBytes + $losFreedBytes;
            print(GC_FILE "$elapsedSeconds\t$totalFreedBytes\n");
        }
    }
}

close(INPUT_FILE);
close(READ_WS_FILE);
close(WRITE_WS_FILE);
close(GC_FILE);

sub getBytes {
    my $stringVal = shift(@_);
    if ($stringVal =~ /^(\d+)(MB|KB|B)$/) {
        my $num = $1;
        my $unit = $2;
        my $multiplier = 0;
        if ($unit eq "MB") {
            $multiplier = 1024 * 1024;
        }
        elsif ($unit eq "KB") {
            $multiplier = 1024;
        }
        elsif ($unit eq "B") {
            $multiplier = 1;
        }
        else {
            die "Unrecognized unit: $unit";
        }
        return $num * $multiplier;
    }
    else {
        die "Incorrectly formatted value: $stringVal";
    }
}

sub calcTimeDiffSeconds {
    my ($timeA, $timeB) = @_;
    my ($hourA, $minA, $secA, $msA);
    my ($hourB, $minB, $secB, $msB);
    if ($timeA =~ /^(\d+):(\d+):(\d+)\.(\d+)$/) {
        ($hourA, $minA, $secA, $msA) = ($1, $2, $3, $4);
    }
    else {
        die "Incorrectly formatted time: $timeA";
    }
    if ($timeB =~ /^(\d+):(\d+):(\d+)\.(\d+)$/) {
        ($hourB, $minB, $secB, $msB) = ($1, $2, $3, $4);
    }
    else {
        die "Incorrectly formatted time: $timeB";
    }
    return ($hourB - $hourA) * 60 * 60 + ($minB - $minA) * 60 + ($secB - $secA) + ($msB - $msA) / 1000.0;
}
