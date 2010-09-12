#!/usr/bin/perl -w
use strict;

my $pso = `ps -efww | grep emerge | grep -v grep`;

if ($pso =~ /^\s*$/)
{
    system("emerge --sync");
    exit (0);	# successful completion
}

exit (1);	# emerge already running
