#!/usr/bin/perl


# Deduplicate log messages recording calls to View.onScrollChanged()
# in View.java, where the log messages have the format
# "NIEL scroll: l t oldl oldt".

use warnings;
use strict;

my $usage = "./deduplicate-scrolling-log.pl log-file";

die $usage unless @ARGV==1;

my $sourceFileName = shift;
my $destFileName = "$sourceFileName.deduplicated";

open(SOURCE_FILE, $sourceFileName);
open(DEST_FILE, "> $destFileName");

my $prevLine = "";
while(<SOURCE_FILE>) {
    my $curLine = $_;
    my $printCurLine = 1;
    if ($curLine =~ /NIEL scroll: \d+ (\d+) \d+ (\d+)/) {
        my $curT = $1;
        my $curOldT = $2;
        if ($prevLine =~ /NIEL scroll: \d+ (\d+) \d+ (\d+)/) {
            my $prevT = $1;
            my $prevOldT = $2;
            if ($curT == $prevT && $curOldT == $prevOldT) {
                $printCurLine = 0;
            }
        }
    }
    if ($printCurLine) {
        print(DEST_FILE $curLine);
    }
    $prevLine = $curLine;
}

close(DEST_FILE);
close(SOURCE_FILE);
