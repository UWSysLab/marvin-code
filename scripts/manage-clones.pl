#!/usr/bin/perl

use warnings;
use strict;

my $PARENT_PACKAGE = "edu.washington.cs.nl35";
my $CLONE_DIR = "/home/nl35/research/android-memory-model/temp";

my $usage = "./manage-clones.pl [create|delete|start|stop] app-path num-clones";
die $usage unless @ARGV == 3;

my ($cmd, $appPath, $numClones) = @ARGV;
if (!($cmd =~ /^create|delete|start|stop$/)) {
    die $usage;
}

my $appName = getAppNameFromPath($appPath);
my $packageName = lc $appName;

if ($cmd =~ /create/) {
    createClones();
}
elsif ($cmd =~ /delete/) {
    deleteClones();
}
elsif ($cmd =~ /start/) {
    startClones();
}
elsif ($cmd =~ /stop/) {
    stopClones();
}

sub createClones {
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
}

sub deleteClones {
    for (my $i = 0; $i < $numClones; $i++) {
        system("adb uninstall $PARENT_PACKAGE.$packageName$i");
    }

    for (my $i = 0; $i < $numClones; $i++) {
        system("rm -r $CLONE_DIR/$appName$i");
    }
}

sub startClones {
    for (my $i = 0; $i < $numClones; $i++) {
        system("adb shell am start -a android.intent.action.MAIN -n $PARENT_PACKAGE.$packageName$i/.MainActivity");
    }
}

sub stopClones {
    for (my $i = 0; $i < $numClones; $i++) {
        system("adb shell am force-stop $PARENT_PACKAGE.$packageName$i");
    }
}

sub getAppNameFromPath {
    my $path = shift;
    my @pathSplit = split(/\//, $path);
    return $pathSplit[@pathSplit - 1];
}
