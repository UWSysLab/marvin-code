# I used these links to learn how to create a module:
# https://perlmaven.com/how-to-create-a-perl-module-for-code-reuse
# https://perldoc.perl.org/Exporter.html

package NielAndroidUtils;
use strict;
use warnings;

use Exporter 'import';

our @EXPORT_OK = qw(parseLogMessage calcTimeDiffSeconds);

sub parseLogMessage {
    my $logMessage = shift;
    if ($logMessage =~ /^(\S+)\s+(\S+)\s+(\d+)\s+(\d+)\s+(\w+)\s+(\S+)\s*:\s*(.*)$/) {
        my ($date, $time, $pid, $tid, $logLevel, $tag, $message) = ($1, $2, $3, $4, $5, $6, $7);
        return ($date, $time, $pid, $tid, $logLevel, $tag, $message);
    }
    return ();
}

sub calcTimeDiffSeconds {
    my ($timeA, $timeB) = @_;
    my ($hourA, $minA, $secA, $msA);
    my ($hourB, $minB, $secB, $msB);
    if ($timeA =~ /^(\d+):(\d+):(\d+)\.(\d+)$/) {
        ($hourA, $minA, $secA, $msA) = ($1, $2, $3, $4);
    }
    else {
        die "Incorrectly formatted time: $timeA";
    }
    if ($timeB =~ /^(\d+):(\d+):(\d+)\.(\d+)$/) {
        ($hourB, $minB, $secB, $msB) = ($1, $2, $3, $4);
    }
    else {
        die "Incorrectly formatted time: $timeB";
    }
    return ($hourB - $hourA) * 60 * 60 + ($minB - $minA) * 60 + ($secB - $secA) + ($msB - $msA) / 1000.0;
}
