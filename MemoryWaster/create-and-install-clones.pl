#!/usr/bin/perl

use warnings;
use strict;

my $usage = "./create-and-install-clones.pl num-clones";
die $usage unless @ARGV == 1;

my $numClones = shift;

for (my $i = 0; $i < $numClones; $i++) {
    system("./clone-project.pl MemoryWaster$i");
}

my $projectDir = `pwd`;
chomp($projectDir);
for (my $i = 0; $i < $numClones; $i++) {
    chdir("$projectDir");
    chdir("../MemoryWaster$i/app/build/outputs/apk/debug");
    system("adb install app-debug.apk");
}
