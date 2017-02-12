#!perl
use warnings;
use strict;

print ("Ingrese su IP");
my $entradaIP=<STDIN>;
print "No es una direccion ip valida" if (! &ipValida($entradaIP));

=pod  ipValida recibe como parametro una cadena y dice si es una direccion ip valida.
=cut
#
# Recibe una cadena que debe tener solo una direccion ip.
# Si la cadena tiene cualquier cosa que no sea una ip regresa 0;
sub ipValida{
    if ($_[0]=~ /^\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b$/)
	{
		return 1;
	}
	else {
		return 0;
	}

}
