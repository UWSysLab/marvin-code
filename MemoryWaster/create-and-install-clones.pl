#!/usr/bin/perl

use warnings;
use strict;

my $PARENT_PACKAGE = "edu.washington.cs.nl35";
my $CLONE_DIR = "..";

my $usage = "./create-and-install-clones.pl app-path num-clones";
die $usage unless @ARGV == 2;

my ($appPath, $numClones) = @ARGV;

my $appName = getAppNameFromPath($appPath);

for (my $i = 0; $i < $numClones; $i++) {
    system("./clone-project.pl $PARENT_PACKAGE $appPath $CLONE_DIR/$appName$i");
}

my $workingDir = `pwd`;
chomp($workingDir);
for (my $i = 0; $i < $numClones; $i++) {
    chdir("$workingDir");
    chdir("$CLONE_DIR/$appName$i/app/build/outputs/apk/debug");
    system("adb install app-debug.apk");
}

sub getAppNameFromPath {
    my $path = shift;
    my @pathSplit = split(/\//, $path);
    return $pathSplit[@pathSplit - 1];
}
