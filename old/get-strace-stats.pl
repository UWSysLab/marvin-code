#!/usr/bin/perl

use warnings;
use strict;

my $usage = "./get-strace-stats.pl strace-file";

die $usage unless @ARGV==1;

my %functionCounts = ();

my $straceFile = shift;
open(STRACE_FILE, $straceFile);
while(<STRACE_FILE>) {
    if ($_ =~ /^(\d+)\s+(\w+)\(/) {
        my $function = $2;
        if (!defined $functionCounts{$function}) {
            $functionCounts{$function} = 0;
        }
        $functionCounts{$function}++;
    }
}
close(STRACE_FILE);

my $total = 0;
for my $function (sort keys %functionCounts) {
    print("$function\t\t$functionCounts{$function}\n");
    $total += $functionCounts{$function};
}
print("Total:\t\t$total\n");
