#!/usr/bin/perl -w
# Josh Holtrop
# 2006-05-05

use strict;

sub usage
{
	print "Usage: $0 [options] command [args]\n";
	print "Options:\n";
	print "  -q           Run <command> on hosts sequentially (default in parallel)\n";
	print "  -s<ssh>      Use <ssh> instead of 'ssh' for a remote shell program\n";
	print "  -u<user>     Use username <user> instead of your own\n";
	print "  -h<hostlist> The hosts to run the command on, comma-separated\n";
	print "               If the -h option is not given, the host list is\n";
	print "               read from standard input, one host per line\n";
	exit(42);
}

my $ssh = 'ssh';
my $user = '';
my $seq = 0;
my @hosts = ();
my @command = ();

for (my $i = 0; $i <= $#ARGV; $i++)
{
	if ($ARGV[$i] eq '-q')
	{
		$seq = 1;
	}
	elsif ($ARGV[$i] =~ /^-s(.*)$/)
	{
		if (length($1) > 0)
		{
			$ssh = $1;
		}
		else
		{
			usage() if ($i == $#ARGV);
			$ssh = $ARGV[++$i];
		}
	}
	elsif ($ARGV[$i] =~ /^-h(.*)$/)
	{
		if (length($1) > 0)
		{
			@hosts = split(/,/, $1);
		}
		else
		{
			usage() if ($i == $#ARGV);
			@hosts = split(/,/, $ARGV[++$i]);
		}
	}
	elsif ($ARGV[$i] =~ /^-u(.*)$/)
	{
		if (length($1) > 0)
		{
			$user = $1;
		}
		else
		{
			usage() if ($i == $#ARGV);
			$user =  $ARGV[++$i];
		}
	}
	else
	{
		# We've reached the command
		@command = splice(@ARGV, $i);
		last;
	}
}

$user .= '@' if ($user ne '');
usage() if ($#command < 0);

if ($#hosts < 0)
{
	# Read hosts from stdin
	while (my $host = <STDIN>)
	{
		chomp($host);
		push(@hosts, $host);
	}
}

foreach my $host (@hosts)
{
	my $f = $seq ? 0 : fork();
	$f || system($ssh, "$user$host", @command);
	exit(0) unless ($f || $seq);         # Exit if not parent and not sequential
}

while (wait() != -1) {}                      # Wait for all children to exit

exit(0);

