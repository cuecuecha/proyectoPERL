#!perl
use warnings;
use strict;
use Term::ReadKey;
=head1 Menu
=pod
  Se necesita instalar apt-get install libterm-readkey-perl

  La funcion menu, recibira un parametro, ya sea configurar, consultar o salir
  
  


=cut
my $op;
my $op2;
my %confCowrie=();
my %confDionaea=();
my %menuP = (                           
    help =>  sub{print"Indica una opción valida\n"},
    1    =>  \&conf,
    2   =>  \&act,
    3   =>  sub { exit }, 
);
my %menuS = (                           
    help =>  sub{print"Indica una opción valida\n"},
    1    =>  \&dionaea,
    2   =>  \&cowrie,
    3   => \&red,
    4   =>  \&menu, 
);

#variables para la funcion red
my $ip;
my $file='interfaces';
if(!open(FH,'<',$file))
{
  warn "No se puede abrir el archivo ",$file," o no existe\n";
  exit();
}

#variables para conf
my $cowrie = 'cowrie.txt';
open COW,"<",$cowrie;
my $id;
my $password;

sub menu{  
  system("clear"); #limpia la pantalla
  while(1){
    print"1) Configurar parámetros del sensor\n";
    print"2) Consultar los parámetros actuales\n";
    print"3) Salir\n";


    print"Que deseas hacer:\n";
    $op=<STDIN>;
    chomp($op);

    if(!$menuP{$op})
    { 
      warn "Comando desconocido: `$op'; Prueba 'help' la siguiente vez\n"; 
    }
    else
    {
      $menuP{$op}->($op);
    }
  }
}

sub act{
  system("clear"); #limpia la pantalla
  while(1){
    print"1) Consultar los parametros de Cowrie\n";
    print"2) Consultar los parametros de Dionaea\n";
    print"3) Consultar los parametros de Red\n";
    print"4) Regresar\n";


    print"Que deseas hacer:\n";
    $op=<STDIN>;
    chomp($op);

    if(($op != 1) && ($op != 2) && ($op != 3) && ($op != 4))
    { 
      warn "Comando desconocido: `$op'; Prueba 'help' la siguiente vez\n"; 
    }
    elsif ($op == 1)
    {
	   &muestraCowrieConf(&leeCowrieConf(\%confCowrie, "cowrie.txt"))
    }
    elsif ($op == 2)
    {
	   &muestraDionaeaConf(&leeDionaeaConf(\%confDionaea, "dionaea.txt"))
    }
    elsif ($op == 3)
    {
	   while(<FH>)
     {
      print $_;
     }
     close INT;
    }
    elsif($op==4)
    {
      return;
    }
  }
}

=head2 conf
=pod
  Esta funcion, es un submenu al elegir la primer opcion
  Esta se encarga de realizar las confguraciones
  Recibe un parametro, ya sea configurar Dionaea, Coerie, configurar Red o salir,
  ésta opcion te regresara al menu principal.

  Ejemplo
    1) Configurar Dionaea
    2) Configurar Cowrie
    3) Configurar Red
    4) Salir

=cut
sub conf{
  system("clear");
  while(1)
  {
    print"1) Configurar Dionaea\n";
    print"2) Configurar Cowrie\n";
    print"3) Configurar Red\n";
    print"4) Salir\n";

    print"Que deseas hacer:\n";
    $op2=<STDIN>;
    chomp($op2);

    if(!$menuS{$op2})
    { 
      warn "Comando desconocido: '$op2'; Prueba 'help' la siguiente vez\n"; 
    }
    else
    {
      $menuS{$op2}->($op2);
    }
  }
}


sub dionaea{
  my $dionaea='dionaea.txt';
  print"Identificador: ";
  chomp(my $id = <STDIN>);
  `perl -pi -e 's/user \=  \"([A-Za-z0-9_])*\"\$/user \= \"$id\"/' $dionaea`;
  print "\nPassword:";
  ReadMode('noecho'); # no imprime
  chomp(my $password = <STDIN>);
  ReadMode(0);        # back to normal
  `perl -pi -e 's/pass \=  \"([A-Za-z0-9_])\"\$/pass \= \"$password\"/' $dionaea`;
  print "\n";
}
sub cowrie{
  print"Identificador: ";
  $id = <STDIN>;
  chomp($id);
  `perl -pi -e 's/username \= ([A-Za-z0-9_\.])*\$/username \= $id/' $cowrie`;
  print "\nPassword:";
  ReadMode('noecho'); # no imprime
  $password = <STDIN>;
  chomp($password);
  ReadMode(0);        # back to normal
  `perl -pi -e 's/password \= ([A-Za-z0-9_\.])*\$/password \= $password/' $cowrie`;
  print "\n";
}

=head2 Red
=pod
    Recibira cinco parametros: IP, MASCARA, NETWORK, BROADCAST, GATEGAY y 
    lo modificara en el archivo "interfaces" que se ubica en /etc/network/

    Ejemplo Red:
      IP:
      MASCARA:
      NETWORK:
      BROADCAST:
      GATEWAY:
=cut

sub red{
  print"\nIP: ";
  $ip=<STDIN>;
  chomp($ip);
  ###  if($ip=~/(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])/)
  if(ipValida($ip))  
  { 
    if($ip=~/^10/)
    {
      print"Es clase A. Te recomiendo una mascara de 255.0.0.0\n";
    }
    elsif($ip=~/^172\.16/)
    {
      print"Es clase B. Te recomiendo una mascara de 255.255.0.0\n";
    }
    elsif($ip=~/^192\.168/)
    {
      print"Es clase C. Te recomiendo una mascara de 255.255.255.0\n";
    }
    else
    {
      print"No pertenece a alguna clase\n";
    }
    `perl -pi -e 's/address (([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\$/address $ip/' $file`;
  }
  else{
    print("No es una ip valida\n");
  }

  print"\nMASCARA: ";
  my $masc=<STDIN>;
  chomp($masc);
  if($masc=~/(255)\.(255|[0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.(255|[0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.(255|[0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])/ && $masc ne $ip)
  { 
    `perl -pi -e 's/netmask (255)\.(255|0)\.(255|0)\.(255|0)\$/netmask $masc/' $file`;
  }
  else{
    print("No es una mascara valida\n");
  }

  print"\nNETWORK: ";
  my $net=<STDIN>;
  chomp($net);
  
  if($net=~/(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])/ && $net ne $ip && $net ne $masc)
  { 
    `perl -pi -e 's/network (([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\$/network $net/' $file`;
  }
  else{
    print("No es valida\n");
  }

  print"\nBROADCAST: ";
  my $broad=<STDIN>;
  chomp($broad);
  if($broad=~/(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])/ && $broad ne $ip && $broad ne $masc && $broad ne $net)
  { 
    `perl -pi -e 's/broadcast (([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\$/broadcast $broad/' $file`;
  }
  else{
    print("No es valida\n");
  }

  print"\nGATEWAY: ";
  my $gate=<STDIN>;
  chomp($gate);
  if($gate=~/(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])/&& $gate ne $broad && $gate ne $net && $gate ne $masc && $gate ne $ip)
  { 
    `perl -pi -e 's/gateway (([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\$/gateway $gate/' $file`;
  }
  else{
    print("No es valida\n");
  }

}

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

    if ($archivo ne '') 
    { # Tenemos un nombre de archivo
	   open CONF, "<", $archivo;

	   while (<CONF>) {
  	    next if (/^\s*#/);  # Comentario, ignorarlo
  	    next if (/^$/);     # Linea vacia, ignorarla.
  	    if (/^.*#/) 
        {
  		    $_ = $';
  	    }
  	    if (/^\s*\[(\w+)\]\s*$/) 
        {  # Inicia una seccion
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

    if ($archivo && ($archivo ne ''))
    { # Guardar en archivo el contenido del hash
    	if ((stat $archivo)[3] > 0) {
    	    print STDERR "Sobre escribiendo el archivo $archivo.\n";
    	}
      	open $fh, ">", $archivo;
          } else {              # Redireccionar la salida a la salida estandar.
      	open $fh, ">&STDOUT";
    }

    # A partir de aqui todo se manda al archivo manejado por $fh
    for my $k (sort keys %$r) 
    {
	   print $fh "[$r->{$k}[0]]\n";
	   for (keys %{$r->{$k}[1]}) 
     {
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

sub leeDionaeaConf {
    my $archivo =  shift @_;
    my ($comml, $linea) = (0, '');

    if ($archivo eq '') { # Tenemos un nombre de archivo
	     return -1;
    }
    open CONF, "<", $archivo;

    while (<CONF>) 
    {
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
    close CONF;
    return $linea;

}

sub muestraDionaeaConf {
      print $_;  
    
}

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

&menu;


