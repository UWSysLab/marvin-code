#!/usr/bin/perl

# This script is meant for use with the CSV files generated by the
# measure-memory binary (whose source code is in the memory-measurement
# directory).

use warnings;
use strict;

my $MS_PRE_ALIGNPOINT = 150;
my $MS_POST_ALIGNPOINT = 200;

my $usage = "./process-memory-data.pl baseline-rss-pages file1 file1-label file1-alignpoint file2 file2-label file2-alignpoint ...\n";
die $usage if @ARGV < 4;
die $usage if @ARGV % 3 != 1;

my $baselinePages = $ARGV[0];

my @fileNames;
my @labels;
my @alignPoints;
for (my $i = 1; $i < @ARGV; $i += 3) {
    push(@fileNames, $ARGV[$i]);
    push(@labels, $ARGV[$i + 1]);
    push(@alignPoints, $ARGV[$i + 2]);
}

print("TranslatedTimestamp,TranslatedRSSMB,WorkingSet\n");
for (my $i = 0; $i < @fileNames; $i++) {
    open(FILE, $fileNames[$i]);
    while (<FILE>) {
        my @lineSplit = split(/,/, $_);
        if (@lineSplit < 2) {
            next;
        }
        my $timestamp = $lineSplit[0];
        if ($timestamp < $alignPoints[$i] - $MS_PRE_ALIGNPOINT or $timestamp > $alignPoints[$i] + $MS_POST_ALIGNPOINT) {
            next;
        }
        my $translatedTimestamp = $timestamp - $alignPoints[$i];
        my $statm = $lineSplit[1];
        my @statmSplit = split(/\s+/, $statm);
        if (@statmSplit < 7) {
            next;
        }
        my $rssPages = $statmSplit[1];
        my $rssMb = $rssPages * 4096 / 1024 / 1024;
        my $baselineMb = $baselinePages * 4096 / 1024 / 1024;
        my $translatedRssMb = $rssMb - $baselineMb;
        print("$translatedTimestamp,$translatedRssMb,$labels[$i]\n");
    }
    close(FILE);
}
