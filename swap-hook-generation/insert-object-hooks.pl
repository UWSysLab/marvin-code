#!/usr/bin/perl

# Given a C++ source file for a class, generate a modified version of that
# source file where the beginning of each class method includes a call to
# either the macro SWAP_PREAMBLE() or the macro SWAP_PREAMBLE_TEMPLATE(),
# depending on whether the method is a template method.
#
# The whitelist-file, if specified, should be a file consisting of method names
# separated by newlines. These methods will not have a preamble in the output
# source file. Any line starting with a pound sign (#) in the whitelist file is
# treated as a comment and ignored.
#
# This script takes advantage of a number of apparent conventions used in the
# ART source code for method definitions, including:
#
# 1) There is a newline after the method signature before the method body.
#
# 2) If the method is a template method, its template parameters are declared
#    on their own line (or lines) before the rest of the method signature.
#
# 3) If the method has a lock safety analysis macro (e.g., SHARED_REQUIRES), it
#    is included on its own line after the method signature.
#
# There may be other assumptions that are not explicitly spelled out above.
# Violation of any of these assumptions will cause the script to work
# improperly or fail.
#
# Finally, note that there may be a few special-case methods that are not
# handled correctly by this script for one reason or another. These methods
# and the corresponding workarounds will be enumerated in another file.

use warnings;
use strict;

my @returnTypes = ("uint32_t", "bool", "void");

my $usage = "./insert-object-hooks.pl source-file class-name [whitelist-file]";
die $usage unless @ARGV==2 or @ARGV==3;

my $file = shift;
my $className = shift;
my $whiteListFile = "";
if (@ARGV == 1) {
   $whiteListFile = shift;
}
my $argvLen = @ARGV;

my @whiteList = ();
if ($whiteListFile ne "") {
    open(WHITELIST, $whiteListFile);
    while(<WHITELIST>) {
        if (!($_ =~ /^#/)) {
            my $methodName = $_;
            chomp($methodName);
            push(@whiteList, $methodName);
        }
    }
    close(WHITELIST);
}

open(FILE, $file);
my @lines = <FILE>;
close(FILE);

my $inTemplate = 0;
my $inDeclaration = 0;
my $expectingLockMacroLine = 0;
my @templateArgs = ();
my @regArgs = ();
my $methodName = "";
my $returnType = "";
foreach my $line (@lines) {
    print($line);

    if ($line =~ /template\s*<(.*)>/) {
        #Full template
        push(@templateArgs, getArgs($1));
    }
    elsif ($line =~ /template\s*<(.*)/) {
        #Start of template
        $inTemplate = 1;
        push(@templateArgs, getArgs($1));
    }
    elsif ($line =~ /(.*)>/ && $inTemplate) {
        #End of template
        $inTemplate = 0;
        push(@templateArgs, getArgs($1));
    }
    elsif ($inTemplate) {
        #Middle of template
        push(@templateArgs, getArgs($line));
    }
    elsif ($line =~ /(inline\s+)*(\S+)\s+${className}::(\S+)\((.*)\).*{/) {
        #Full method declaration
        $returnType = $2;
        $methodName = $3;
        push(@regArgs, getArgs($4));

        printPreamble($methodName, $returnType, \@templateArgs, \@regArgs);
        @templateArgs = ();
        @regArgs = ();
    }
    elsif ($line =~ /(inline\s+)*(\S+)\s+${className}::(\S+)\((.*)\)/) {
        #Full method declaration except for lock macro line
        $returnType = $2;
        $methodName = $3;
        $expectingLockMacroLine = 1;
        push(@regArgs, getArgs($4));
    }
    elsif ($line =~ /(inline\s+)*(\S+)\s+${className}::(\S+)\((.*)/) {
        #Start of method declaration
        $inDeclaration = 1;
        $returnType = $2;
        $methodName = $3;
        push(@regArgs, getArgs($4));
    }
    elsif ($line =~ /(.*)\).*{/ && $inDeclaration) {
        #End of method declaration
        $inDeclaration = 0;
        push(@regArgs, getArgs($1));

        printPreamble($methodName, $returnType, \@templateArgs, \@regArgs);
        @templateArgs = ();
        @regArgs = ();
    }
    elsif ($line =~ /(.*)\)/ && $inDeclaration) {
        #End of method declaration except for lock macro line
        $inDeclaration = 0;
        $expectingLockMacroLine = 1;
        push(@regArgs, getArgs($1));
    }
    elsif ($inDeclaration) {
        #Middle of method declaration
        push(@regArgs, getArgs($line));
    }
    elsif ($expectingLockMacroLine) {
        #Lock macro line
        $expectingLockMacroLine = 0;

        printPreamble($methodName, $returnType, \@templateArgs, \@regArgs);
        @templateArgs = ();
        @regArgs = ();
    }
}

sub onWhiteList {
    my $methodName = shift;

    foreach my $name (@whiteList) {
        if ($methodName eq $name) {
            return 1;
        }
    }
    return 0;
}

sub listToCommaSeparatedString {
    my $string = "";
    for (my $i = 0; $i < @_; $i++) {
        $string .= "$_[$i]";
        if ($i < @_ - 1) {
            $string .= ", ";
        }
    }
    return $string;
}

sub printPreamble {
    my $methodName = shift;
    my $returnType = shift;
    my $templateArgsRef = shift;
    my $regArgsRef = shift;

    if (onWhiteList($methodName)) {
        return;
    }

    my $regArgString = listToCommaSeparatedString(@{$regArgsRef});
    if (@templateArgs > 0) {
        my $templateArgString = listToCommaSeparatedString(@{$templateArgsRef});
        if ($returnType eq "void") {
            print("  SWAP_PREAMBLE_TEMPLATE_VOID($methodName, $className, GATHER_TEMPLATE_ARGS($templateArgString), $regArgString)\n");
        }
        else {
            print("  SWAP_PREAMBLE_TEMPLATE($methodName, $className, $returnType, GATHER_TEMPLATE_ARGS($templateArgString), $regArgString)\n");
        }
    }
    else {
        if ($returnType eq "void") {
            print("  SWAP_PREAMBLE_VOID($methodName, $className, $regArgString)\n");
        }
        else {
            print("  SWAP_PREAMBLE($methodName, $className, $returnType, $regArgString)\n");
        }
    }
}

sub getArgs {
    my @result = ();
    my $str = shift;
    my @split = split(/,/, $str);
    foreach my $pair (@split) {
        if ($pair =~ /^\s+(.*)/) {
            $pair = $1;
        }
        chomp($pair);
        if (length($pair) > 0) {
            my @pairSplit = split(/\s+/, $pair);
            my $arg = $pairSplit[@pairSplit - 1];
            push(@result, $arg);
        }
    }
    return @result;
}
