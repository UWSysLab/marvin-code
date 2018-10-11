#!/usr/bin/perl

use warnings;
use strict;

my $usage = "./plot-gc-collection-working-set-log.pl inputPrefix outputPrefix";
die $usage unless @ARGV == 2;

my ($inputPrefix, $outputPrefix) = @ARGV;

my $readWsFile = "$inputPrefix-read-working-set.txt";
my $writeWsFile = "$inputPrefix-write-working-set.txt";
my $gcFile = "$inputPrefix-gc-collection.txt";

my $scriptFile = "temp-script.txt";
my $wsPlotFile = "$outputPrefix-working-set.pdf";
my $gcPlotFile = "$outputPrefix-gc-collection.pdf";

open(SCRIPT_FILE, "> $scriptFile");
print(SCRIPT_FILE "set terminal pdfcairo\n");
print(SCRIPT_FILE "set output \"$wsPlotFile\"\n");
print(SCRIPT_FILE "set xlabel \"Elapsed time (s)\"\n");
print(SCRIPT_FILE "set ylabel \"Working set size (bytes)\"\n");
print(SCRIPT_FILE "plot \"$readWsFile\" with linespoints, \"$writeWsFile\" with linespoints\n");
print(SCRIPT_FILE "set ylabel \"Garbage collected (bytes)\"\n");
print(SCRIPT_FILE "set output \"$gcPlotFile\"\n");
print(SCRIPT_FILE "plot \"$gcFile\" with linespoints\n");
close(SCRIPT_FILE);

system("gnuplot $scriptFile");

system("rm $scriptFile");
