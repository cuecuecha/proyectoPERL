#!perl
use warnings;
use strict;
use Term::ReadKey;

##apt-get install libterm-readkey-perl


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
    2   =>  \&crowrie,
    3   => \&red,
    4   =>  \&menu, 
);

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
chomp(my $password = <STDIN>),"\n";
print "Password:";
ReadMode('noecho'); # no imprime
chomp(my $password = <STDIN>);
ReadMode(0);        # back to normal
print "\n";
}
sub crowrie{
   print"configurar";
}
sub red{
  print"configurar";
}

&menu;