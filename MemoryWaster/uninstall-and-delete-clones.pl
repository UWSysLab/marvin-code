#!/usr/bin/perl

use warnings;
use strict;

my $PARENT_PACKAGE = "edu.washington.cs.nl35";
my $CLONE_DIR = "..";

my $usage = "./uninstall-and-delete-clones.pl app-name num-clones";
die $usage unless @ARGV == 2;

my ($appName, $numClones) = @ARGV;

my $packageName = lc $appName;

for (my $i = 0; $i < $numClones; $i++) {
    system("adb uninstall $PARENT_PACKAGE.$packageName$i");
}

for (my $i = 0; $i < $numClones; $i++) {
    system("rm -r $CLONE_DIR/$appName$i");
}
