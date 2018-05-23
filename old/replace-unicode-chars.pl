#!/usr/bin/perl

# For each line in standard input, this script will replace the file at that
# path with a copy of the file that has the Unicode copyright symbol replaced
# with a 'c' character.

use warnings;
use strict;

die "Don't put in file names as arguments! Pipe the list of file names into ",
    "STDIN!",
    unless @ARGV==0;

while(<>) {
    chomp;
    my $oldFile = $_;
    my $newFile = "$_.new";
    open(OLD_FILE, $oldFile);
    open(NEW_FILE, "> $newFile");

    while(<OLD_FILE>) {
        for (my $i = 0; $i < length $_; $i++) {
            my $char = substr $_, $i, 1;
            my $ord = ord $char;
            if ($ord == 194) {
                $char = "c";
            }
            elsif ($ord == 169) {
                $char = "";
            }
            print(NEW_FILE $char);
        }
    }

    close(OLD_FILE);
    close(NEW_FILE);

    system("mv $newFile $oldFile");
}
