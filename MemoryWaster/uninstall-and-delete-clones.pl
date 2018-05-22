#!/usr/bin/perl

use warnings;
use strict;

my $usage = "./uninstall-and-delete-clones.pl num-clones";
die $usage unless @ARGV == 1;

my $numClones = shift;

for (my $i = 0; $i < $numClones; $i++) {
    system("adb uninstall edu.washington.cs.nl35.memorywaster$i");
}

for (my $i = 0; $i < $numClones; $i++) {
    system("rm -r ../MemoryWaster$i");
}
