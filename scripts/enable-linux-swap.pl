#!/usr/bin/perl

use warnings;
use strict;

my $SWAPFILE_PATH = "/data/local/nieltest/swapfile";

print("Enabling swapfile at location $SWAPFILE_PATH\n");
system("adb root");
my $lsOutput = `adb shell ls $SWAPFILE_PATH 2>&1`;
if ($lsOutput =~ /No such file or directory/) {
    print(STDERR "Error: swapfile not found\n");
    exit(1);
}
system("adb shell swapon $SWAPFILE_PATH");
system("adb shell \"echo 0,0,0,0,0,0 > /sys/module/lowmemorykiller/parameters/minfree\"");

print("\n");
print("cat /proc/swaps:\n");
system("adb shell cat /proc/swaps");
print("\n");
print("cat /sys/module/lowmemorykiller/parameters/minfree:\n");
system("adb shell cat /sys/module/lowmemorykiller/parameters/minfree");
