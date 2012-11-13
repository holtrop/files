#!/usr/bin/perl -w

use strict;

foreach my $arg (@ARGV)
{
    my $out = $arg;
    $out =~ s/\....$//;
    $out =~ s/\,/\\,/g;
    system('mplayer', '-vo', 'null', '-ao', "pcm:file=$out.wav", $arg);
}

