#!/usr/bin/perl

use warnings;
use strict;

#my %confC;
#my %newOpc = (seccion=>"otra_seccion", parametro => "nuevo", valor=>"valor" );
#&leeCowrieConf(\%confC, "./cowrie.cfg");
#&addOpcionCowrie(\%confC, \%newOpc);
#&muestraCowrieConf(\%confC, "./ninguno.txt");
my %confD;
my $l =  &leeDioneaConf("./dionea.cfg");
&procesaDioneaConf(\%confD, $l);

#for (keys %confD) {
#    print $_, "\n";
#}

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
	    next if (/^\s*#/);  # Comentario, ignorarlo
	    next if (/^$/);     # Linea vacia, ignorarla.
	    if (/^.*#/) {
		$_ = $';
	    }
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

=head2 addOpcionCowrie

 Agrega una opcion en una seccion.

 Recibe un hash con las opciones cargadas desde el archivo de configuracion
 y un hash con el siguiente formato:
 entrada = {
              seccion   => "nombre"
              parametro => "nombre de la opcion"
              valor     => "valor del parametro"
           }

 agrega esas opciones al hash para estar disponibles y ser escritas a un
 archivo cuando sea requerido.
=cut
sub addOpcionCowrie {
    my ($rc, $e) = @_;
    my $llave = &lugarCowrieConf ($rc, $e->{seccion});

    if ($llave == -1) { # Agregamos una nueva seccion
	$llave = 0;
	for(sort keys %$rc) { $llave++; }
	$rc->{$llave}[0] = $e->{seccion};
    }
    $rc->{$llave}[1]{$e->{parametro}} = $e->{valor};
}

# lugarCowrieConf recibe un hash y el nombre de una seccion.
# Regresa el lugar en el hash donde se encuentra, -1 si no existe.
# El valor -1 se utiliza para indicar que se puede agregar al hash.
sub lugarCowrieConf {
    my ($rc, $seccion) = @_;

    for(sort keys %$rc) {
	return $_ if ($seccion eq $rc->{$_}[0]);
    }
    return -1;
}

sub leeDioneaConf {
    my $archivo =  shift @_;
    my ($comml, $linea) = (0, '');

    if ($archivo eq '') { # Tenemos un nombre de archivo
	return -1;
    }
    open CONF, "<", $archivo;

    while (<CONF>) {
	next if (/^\s*$/);    # Linea vacia, ignorarla.
	next if (/^\s*#/); # Comentario, ignorarlo.
	next if (m|^\s*//|); # Comentario, ignorarlo,
	if (m|^\s*/\*|) {  # Inicia comentario multilinea
	    $comml = 1;
	    do {
		$_ = <CONF>;
		if ( m|^\s*\*/|) { # Termina comentario multilinea
		    $comml = 0;
		}
	    } while ($comml);
	    next;
	} elsif (m|://.*$|) {
	    $linea .= $_;
	} elsif (m|\s*//.*$|) {
	    $linea .= $`;
	} else {
	    chomp $_;
	    $linea .= $_;
	}
    }
    return $linea;
}

sub procesaDioneaConf {
    my ($rc, $linea) = @_;
    my ($i, $delimitador) = (0, 0);
    my ($seccion, $flag, $param, $valor, $llave);
    $linea =~ s/^\s*//;
    while ($linea) {
	if ($linea=~/([\w_-]+)\s*=\s*\{/) {
	    $llave = $1;
	    $i = length($&);
	    $delimitador = 1;
	    while ($delimitador > 0) {
		$i++;
		if (substr($linea, $i, 1) eq '{') {
		    $delimitador++;
		} elsif (substr($linea, $i, 1) eq '}') {
		    $delimitador--;
		}
	    }
	    $seccion = substr ($linea, 0, $i+1);
	    $seccion =~ s/^\s*\w+\s*=\s*\{\s*//;
	    $seccion =~ s/\s*\}\s*$//;
	    $rc->{$llave} = &procesahash(\$seccion);
	    print $llave, "\n";
	    $linea = substr ($linea, $i+1, length($linea) - $i + 2);
	    $i = 0;
	}
    }
    return $rc;
}

sub procesahash {
    my $rl = shift @_;
    my (%hash, $seccion) = ((), '');
    my ($flag, $i, $delimitador)=('', 0, 0);
    $$rl =~ s/^\s*//;
    if ($$rl=~/([\w_-]+)\s*=\s*/) {
	$llave = $1;
	if ($'=~/^\{/) {
	    $i = length($&);
	    $delimitador = 1;
	    while ($delimitador > 0) {
		$i++;
		if (substr($$rl, $i, 1) eq '{') {
		    $delimitador++;
		} elsif (substr($$rl, $i, 1) eq '}') {
		    $delimitador--;
		}
	    }
	    $seccion = substr ($$rl, 0, $i+1);
	    $seccion =~ s/^\s*\w+\s*=\s*\{\s*//;
	    $seccion =~ s/\s*\}\s*$//;
	    $rc->{$llave} = &procesahash($seccion);
	}
	if ($'=~/^\[/) {
	    $i = length($&);
	    $delimitador = 1;
	    while ($delimitador > 0) {
		$i++;
		if (substr($$rl, $i, 1) eq '[') {
		    $delimitador++;
		} elsif (substr($$rl, $i, 1) eq ']') {
		    $delimitador--;
		}
	    }
	    $seccion = substr ($$rl, 0, $i+1);
	    $seccion =~ s/^\s*\w+\s*=\s*\{\s*//;
	    $seccion =~ s/\s*\}\s*$//;
	    $rc->{$llave} = &procesahash($seccion);
	}
	print $llave, "\n";
	$linea = substr ($linea, $i+1, length($linea) - $i + 2);
	$i = 0;
    }
    return \%hash;
}

sub muestraDioneaConf {
    print $_;
}

sub existeArchivo {
    return 1 if (stat $_[0])[3];
    return 0;
}
