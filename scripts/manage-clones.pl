#!/usr/bin/perl

use warnings;
use strict;

my $PARENT_PACKAGE = "edu.washington.cs.nl35";
my $CLONE_DIR = "/home/nl35/research/android-memory-model/temp";
my $DEFAULT_ACTIVITY_NAME = "MainActivity";

my $usage =   "usage: ./manage-clones.pl {create|delete|install|uninstall|start|stop} ...\n"
            . "       ./manage-clones.pl create app-path num-clones\n"
            . "       ./manage-clones.pl install app-path num-clones\n"
            . "       ./manage-clones.pl start  app-path num-clones start-delay activity-name\n"
            . "       ./manage-clones.pl stop   app-path num-clones\n"
            . "       ./manage-clones.pl uninstall app-path num-clones\n"
            . "       ./manage-clones.pl delete app-path num-clones\n"
            ;

my ($cmd, $appPath, $numClones, $startDelay, $activityName);

$cmd = $ARGV[0];
if (!($cmd =~ /^create|delete|install|uninstall|start|stop$/)) {
    die $usage;
}

if ($cmd =~ /^create|delete|install|uninstall|stop$/) {
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
    if (@ARGV == 5) {
        $appPath = $ARGV[1];
        $numClones = $ARGV[2];
        $startDelay = $ARGV[3];
        $activityName = $ARGV[4];
        print("Running command $cmd; appPath $appPath, numClones $numClones, startDelay $startDelay, activityName $activityName\n");
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
elsif ($cmd =~ /^install$/) {
    installClones();
}
elsif ($cmd =~ /^uninstall$/) {
    uninstallClones();
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
}

sub installClones {
    my $workingDir = `pwd`;
    chomp($workingDir);
    for (my $i = 0; $i < $numClones; $i++) {
        chdir("$workingDir");
        chdir("$CLONE_DIR/$appName$i/app/build/outputs/apk/debug");
        system("adb install app-debug.apk");
    }
}

sub uninstallClones {
    for (my $i = 0; $i < $numClones; $i++) {
        system("adb uninstall $PARENT_PACKAGE.$packageName$i");
    }
}

sub deleteClones {
    for (my $i = 0; $i < $numClones; $i++) {
        system("rm -r $CLONE_DIR/$appName$i");
    }
}

sub startClones {
    for (my $i = 0; $i < $numClones; $i++) {
        system("adb shell am start -a android.intent.action.MAIN -n $PARENT_PACKAGE.$packageName$i/.$activityName");
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
