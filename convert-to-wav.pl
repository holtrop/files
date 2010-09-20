#!/usr/bin/perl -w

use strict;

foreach my $arg (@ARGV)
{
	my $out = $arg;
	$out =~ s/\....$//;
	system('mplayer', '-vo', 'null', '-ao', "pcm:file=$out.wav", $arg);
}

