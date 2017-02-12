#!perl
use warnings;
use strict;

print ("Ingrese su IP");
print &ip;

sub ip{

my $entradaIP=<STDIN>;
	if ($entradaIP=~ m/\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/)
	{
		return 1;

	}
	else {
		return 0;
	}

}