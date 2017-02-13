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
  print"configurar";
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
  print"Identificador: ";
  chomp(my $id = <STDIN>);
  print "\nPassword:";
  ReadMode('noecho'); # no imprime
  chomp(my $password = <STDIN>);
  ReadMode(0);        # back to normal
  print "\n";
}
sub cowrie{
   print"configurar";
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
  if($ip=~/(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])/)
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

&menu;

close FH;
