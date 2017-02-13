#!perl
use warnings;
use strict;

print ("Ingrese la cadena");
my $cadena=<STDIN>;
print "No es una cadena valida" if (!&cadenaValida($cadena));

=pod  cadenaValida recibe como parametro una cadena y dice si es valida.
=cut
sub cadenaValida{
    if ($_[0]=~/\w/g)
	{
		return 1;
	}
	else {
		return 0;
	}

}
