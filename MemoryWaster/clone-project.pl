#!/usr/bin/perl

use warnings;
use strict;

# This script creates and compiles a copy of an Android Studio project that is
# identical except for having a different app name and application ID.
#
# The "parent package name" passed in as an argument is the prefix before the
# app name in the package hierarchy; i.e., for an app called "FooBar" where the
# code is in package "com.mycompany.foobar", the parent package name is
# "com.mycompany".
#
# There are a few restrictions that must apply for this script to work on a
# project:
#
# 1) There must be a single module called "app" in the project.
#
# 2) All Java source files must be in the top-level package of the app
#    ("com.mycompany.foobar" in the above example).
#
# 3) There must not be any JNI code in the project.
#
# There may be other restrictions as well. For best results, make your app as
# simple as possible.

my $usage = "./clone-project.pl parent-package-name app-path clone-path";

die $usage unless @ARGV == 3;

my ($parentPackage, $appPath, $clonePath) = @ARGV;

my $appName = getAppNameFromPath($appPath);
my $copyName = getAppNameFromPath($clonePath);

my $destParentDir = "$clonePath/..";

system("cp -r $appPath $clonePath");
chdir("$clonePath");

my $parentPackagePath = $parentPackage =~ s/\./\//gr;

my $oldPackageName = lc $appName;
my $newPackageName = lc $copyName;
system("mv $clonePath/app/src/main/java/$parentPackagePath/$oldPackageName $clonePath/app/src/main/java/$parentPackagePath/$newPackageName");

my $activityAwkCmd = "{if (/^package $parentPackage.$oldPackageName;\$/) { print \"package $parentPackage.$newPackageName;\" } else { print \$_; }}";
my $codeDir = "$clonePath/app/src/main/java/$parentPackagePath/$newPackageName";

my $codeDirLsOutput = `ls $codeDir`;
my @codeFiles = split(/\s+/, $codeDirLsOutput);
for my $codeFile (@codeFiles) {
    system("mv $codeDir/$codeFile $codeDir/$codeFile.old");
    system("awk '$activityAwkCmd' $codeDir/$codeFile.old > $codeDir/$codeFile");
}

my $manifestAwkCmd = "{if (/^    package=\"$parentPackage.$oldPackageName\">\$/) { print \"    package=\\\"$parentPackage.$newPackageName\\\">\";} else { print \$_; }}";
my $manifestDir = "$clonePath/app/src/main";
system("mv $manifestDir/AndroidManifest.xml $manifestDir/AndroidManifest.xml.old");
system("awk '$manifestAwkCmd' $manifestDir/AndroidManifest.xml.old > $manifestDir/AndroidManifest.xml");

my $buildGradleAwkCmd = "{if (/^        applicationId \"$parentPackage.$oldPackageName\"\$/) { print \"        applicationId \\\"$parentPackage.$newPackageName\\\"\"; } else { print \$_; }}";
system("mv $clonePath/app/build.gradle $clonePath/app/build.gradle.old");
system("awk '$buildGradleAwkCmd' $clonePath/app/build.gradle.old > $clonePath/app/build.gradle");

my $stringsAwkCmd = "{if (/^    <string name=\"app_name\">$appName<\\/string>\$/) { print \"    <string name=\\\"app_name\\\">$copyName</string>\" ; } else { print \$_; }}";
my $stringsDir = "$clonePath/app/src/main/res/values";
system("mv $stringsDir/strings.xml $stringsDir/strings.xml.old");
system("awk '$stringsAwkCmd' $stringsDir/strings.xml.old > $stringsDir/strings.xml");
system("rm $stringsDir/strings.xml.old");

system("./gradlew assemble");

sub getAppNameFromPath {
    my $path = shift;
    my @pathSplit = split(/\//, $path);
    return $pathSplit[@pathSplit - 1];
}
