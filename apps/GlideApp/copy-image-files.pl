#!/usr/bin/perl

# Copy the image files to be used by GlideApp into the app's local files
# directory on an Android device. This script currently uses a single source
# image to create all of the destination images.

use warnings;
use strict;

my $usage = "./copy-image-files.pl num-files image-file";
die $usage unless @ARGV == 2;
my ($numFiles, $imageFile) = @ARGV;

system("adb root");

# Identify the username corresponding to the app.
my $userName = `adb shell ls -la /data/user/0/edu.washington.cs.nl35.glideapp/files | head -n 2 | tail -n 1 | awk '{print \$3}'`;
chomp($userName);
print("Using user name $userName\n");

for (my $i = 0; $i < $numFiles; $i++) {
    my $destFile = "/data/user/0/edu.washington.cs.nl35.glideapp/files/image$i.png";
    system("adb push $imageFile $destFile");
    system("adb shell chown $userName:$userName $destFile");
}
