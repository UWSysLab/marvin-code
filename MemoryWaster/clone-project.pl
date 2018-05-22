#!/usr/bin/perl

use warnings;
use strict;

my $usage = "./clone-project.pl clone-name";

die $usage unless @ARGV == 1;

my $copyName = shift;

my $destParentDir = "..";
my $destDir = "$destParentDir/$copyName";

system("cp -r . $destDir");
chdir("$destDir");

my $packageName = lc $copyName;
system("mv $destDir/app/src/main/java/edu/washington/cs/nl35/memorywaster $destDir/app/src/main/java/edu/washington/cs/nl35/$packageName");

my $activityAwkCmd = "{if (/^package edu\\.washington\\.cs\\.nl35\\.memorywaster;\$/) { print \"package edu.washington.cs.nl35.$packageName;\" } else { print \$_; }}";
my $codeDir = "$destDir/app/src/main/java/edu/washington/cs/nl35/$packageName";

system("mv $codeDir/MainActivity.java $codeDir/MainActivity.java.old");
system("awk '$activityAwkCmd' $codeDir/MainActivity.java.old > $codeDir/MainActivity.java");

system("mv $codeDir/BaseActivity.java $codeDir/BaseActivity.java.old");
system("awk '$activityAwkCmd' $codeDir/BaseActivity.java.old > $codeDir/BaseActivity.java");

system("mv $codeDir/CompactingTriggerActivity.java $codeDir/CompactingTriggerActivity.java.old");
system("awk '$activityAwkCmd' $codeDir/CompactingTriggerActivity.java.old > $codeDir/CompactingTriggerActivity.java");

my $manifestAwkCmd = "{if (/^    package=\"edu\\.washington\\.cs\\.nl35\\.memorywaster\">\$/) { print \"    package=\\\"edu.washington.cs.nl35.$packageName\\\">\";} else { print \$_; }}";
my $manifestDir = "$destDir/app/src/main";
system("mv $manifestDir/AndroidManifest.xml $manifestDir/AndroidManifest.xml.old");
system("awk '$manifestAwkCmd' $manifestDir/AndroidManifest.xml.old > $manifestDir/AndroidManifest.xml");

my $buildGradleAwkCmd = "{if (/^        applicationId \"edu\.washington\.cs\.nl35\.memorywaster\"\$/) { print \"        applicationId \\\"edu.washington.cs.nl35.$packageName\\\"\"; } else { print \$_; }}";
system("mv $destDir/app/build.gradle $destDir/app/build.gradle.old");
system("awk '$buildGradleAwkCmd' $destDir/app/build.gradle.old > $destDir/app/build.gradle");

my $stringsAwkCmd = "{if (/^    <string name=\"app_name\">MemoryWaster<\\/string>\$/) { print \"    <string name=\\\"app_name\\\">$copyName</string>\" ; } else { print \$_; }}";
my $stringsDir = "$destDir/app/src/main/res/values";
system("mv $stringsDir/strings.xml $stringsDir/strings.xml.old");
system("awk '$stringsAwkCmd' $stringsDir/strings.xml.old > $stringsDir/strings.xml");
system("rm $stringsDir/strings.xml.old");

system("./gradlew assemble");
