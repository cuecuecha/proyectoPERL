#!/usr/bin/perl

use warnings;
use strict;

#my %confC;
#&leeCowrieConf(\%confD, "./cowrie.cfg");
#&muestraCowrieConf(\%confC, "./ninguno.txt");

my %confD;
&leeDioneaConf(\%confD, "./dionea.cfg");

=head2 leeCowrieConf

 Recibe un hash y el nombre del archivo donde esta la configuracion.
 Entrega una referencia a un hash con la estructura:

 configuracion => {
     <num> => [ "nombre de seccion",
                {
                  "parametro 1" => "valor 1",
                   ...
                  "parametro n" => "valor n",
                }
              ]
    }
 La rutina revisa que haya recibido un nombre archivo no vacio, si no es asi regresa el valor -1.
=cut
sub leeCowrieConf {
    my ($rc, $archivo) = @_;
    my ($nombre, $seccion) = ('', -1);

    if ($archivo ne '') { # Tenemos un nombre de archivo
	open CONF, "<", $archivo;

	while (<CONF>) {
	    next if (/^\s*#/);
	    next if (/^$/);
	    if (/^\s*\[(\w+)\]\s*$/) {  # Inicia una seccion
		$nombre = $1;
		$seccion++;
		$rc->{$seccion} = [$nombre, {} ];
	    } else {
		if (/^\s*\b([\w_-]+)\b\s*=\s*(.*)\s*$/){ # parametro = valor
		    $rc->{$seccion}[1]{$1} = $2;
		}
	    }
	}
	close CONF;
    } else {
	return -1;
    }
    return $rc;
}

=head2 muestraCowrieConf
 Muestra el contenido de la configuracion de Cowrie desde un hash que antes
 haya pasado por la rutina leeCowrieConf.

 Si recibe el nombre de un archivo como segundo argumento, entonces guarda
 la configuracion en dicho archivo.
=cut
sub muestraCowrieConf {
    my $r = shift @_;
    my $archivo = shift @_;
    my $fh;

    if ($archivo && ($archivo ne '')) { # Guardar en archivo el contenido del hash
	if ((stat $archivo)[3] > 0) {
	    print STDERR "Sobre escribiendo el archivo $archivo.\n";
	}
	open $fh, ">", $archivo;
    } else {              # Redireccionar la salida a la salida estandar.
	open $fh, ">&STDOUT";
    }

    # A partir de aqui todo se manda al archivo manejado por $fh
    for my $k (sort keys %$r) {
	print $fh "[$r->{$k}[0]]\n";
	for (keys %{$r->{$k}[1]}) {
	    print $fh $_,' = ', $r->{$k}[1]{$_}, "\n";
	}
	print $fh "\n";
    }
    close $fh;
}

sub leeDioneaConf {
    my ($rc, $archivo) = @_;
    my $linea = '';

    if ($archivo ne '') { # Tenemos un nombre de archivo
	open CONF, "<", $archivo;

	while (<CONF>) {
	    $linea .= $_;
	}
	close CONF;
    } else {
	return -1;
    }
    print $linea, "\n";
    return $rc;
}

sub muestraDioneaConf {
    print $_;
}

sub existeArchivo {
    return 1 if (stat $_[0])[3];
    return 0;
}
