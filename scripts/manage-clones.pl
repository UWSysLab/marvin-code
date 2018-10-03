#!/usr/bin/perl

use warnings;
use strict;

my $PARENT_PACKAGE = "edu.washington.cs.nl35";
my $CLONE_DIR = "/home/nl35/research/android-memory-model/temp";

my $usage =   "usage: ./manage-clones.pl {create|delete|start|stop} ...\n"
            . "       ./manage-clones.pl create app-path num-clones\n"
            . "       ./manage-clones.pl start  app-path num-clones start-delay\n"
            . "       ./manage-clones.pl stop   app-path num-clones\n"
            . "       ./manage-clones.pl delete app-path num-clones\n"
            ;

my ($cmd, $appPath, $numClones, $startDelay);

$cmd = $ARGV[0];
if (!($cmd =~ /^create|delete|start|stop$/)) {
    die $usage;
}

if ($cmd =~ /^create|delete|stop$/) {
    if (@ARGV == 3) {
        $appPath = $ARGV[1];
        $numClones = $ARGV[2];
        print("Running command $cmd; appPath $appPath, numClones $numClones\n");
    }
    else {
        die $usage;
    }
}

if ($cmd =~ /^start$/) {
    if (@ARGV == 4) {
        $appPath = $ARGV[1];
        $numClones = $ARGV[2];
        $startDelay = $ARGV[3];
        print("Running command $cmd; appPath $appPath, numClones $numClones, startDelay $startDelay\n");
    }
    else {
        die $usage;
    }
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
        if ($i < $numClones - 1) {
            sleep $startDelay;
        }
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
