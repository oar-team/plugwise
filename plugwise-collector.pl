#!/usr/bin/perl
use strict;
use warnings;

use Device::Plugwise;

my $TIMEOUT = 60;


############################# fichier dbutils que j'arrive pas à importer
use DBI;

# (re)initialise la base de données
sub initbdd {
  my $dbh = connecttodb();
  $dbh->do("DROP TABLE IF EXISTS record, circlegroup, circle");
  $dbh->do("CREATE TABLE IF NOT EXISTS record (id INTEGER AUTO_INCREMENT UNIQUE, circleid VARCHAR(10), date DATETIME, value FLOAT, recdate DATETIME, PRIMARY KEY (circleid, date))");
  $dbh->do("CREATE TABLE IF NOT EXISTS circlegroup (id INTEGER AUTO_INCREMENT UNIQUE, name VARCHAR(20), circleid VARCHAR(10))");
  $dbh->do("CREATE TABLE IF NOT EXISTS circle (id INTEGER AUTO_INCREMENT UNIQUE, name VARCHAR(20), address VARCHAR(10) PRIMARY KEY, historyindex INTEGER DEFAULT -1)");
  $dbh->disconnect();
}


# connecte à la base de donner et retourne le connecteur
sub connecttodb {
  return DBI->connect("DBI:mysql:database=plugwise;host=localhost", "boutserin", "bouh");
#    or die "Cannot connect: " . $DBI::errstr;
}

# enregistre la valeur $value de la date $date pour le circle $circle
sub record {
  my($circle, $date, $value, $recdate) = @_;

#print "record($circle, $date, $value, $recdate)\n";

#  my $test = getrecord($circle, $date);
#  if $test->[0]->{'value'}

  my $dbh = connecttodb();
  $dbh->do("INSERT INTO record (circleid, date, value, recdate) VALUES('$circle', $date, $value, $recdate);");
  $dbh->disconnect();
}


# créer un nouveau circle dans la bdd
sub createcircle {
  my $circle = shift(@_);

  my $dbh = connecttodb();
  $dbh->do("INSERT INTO circle (name, address) VALUES('$circle', '$circle');");
  $dbh->disconnect();
}

# envoie un select à mysql et retourne le résultat
# Le résultat est une référence sur un tableau avec sur chaque ligne une référence sur un hash contenant les noms du champ en clefs associées à leur valeur
sub selectfromdb {
  my $stmt = shift(@_);
  my $results = [];

  my $dbh = connecttodb();

  my $sth = $dbh->prepare($stmt);
  $sth->execute();

  my $i = 0;
  while (my $ref = $sth->fetchrow_hashref()) {
    $results->[$i] = $ref;
    $i++;
  }

  $sth->finish();

  $dbh->disconnect();

  return $results;
}


# select historyindex de la table circle à partir de circle
sub checkcircle {
  my $circle = shift(@_);

  my $stmt = "SELECT historyindex FROM circle WHERE name = '$circle'";

  my $blob = selectfromdb($stmt);

  if(defined $blob->[0] ){
print "$circle 's historyindex = ", $blob->[0], "\n";

    return $blob->[0];
  }else {return -2;}
}


#################################

sub convertdate {
  my $date = shift(@_);

  $date =~ s/(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/"$1-$2-$3 $4:$5:00"/;

  return $date;
}







###################################

my $plugwise = Device::Plugwise->new(device => '/dev/ttyUSB0');

initbdd();

# début
my $circle = '7291CD';

### voir le statut pour récupérer l'index
$plugwise->command('status', $circle);
my $message = $plugwise->read($TIMEOUT);
#print $message->{"body"}[6], ":", $message->{"body"}[7], "\n";
my $lastindex = $message->{"body"}[7];
### la date doit être convertie
my $recdate = convertdate($message->{"body"}[9]);
#print "recdate : ", $recdate, "\n";


#print $message->{"schema"}, "\n";
#foreach(@{$message->{"body"}}){
#  print $_, "\n";
#}

### voir la base de données pour connaître le dernier index enregistré
my $dbindex = checkcircle($circle);
#print "dbindex = $dbindex\n";

##### si le circle n'existe pas, l'ajouter
if($dbindex < -1){
 createcircle($circle); 
}

### journaliser tous les index à enregistrer


### récupérer les index nécessaires

$plugwise->command('history', '7291CD', $lastindex-1);
$message = $plugwise->read($TIMEOUT);
# foreach(@{$message->{"body"}}){
#   print $_, "\n";
# }

### enregistrer les index récupérés
#print "record(", $message->{"body"}[1], ",", convertdate($message->{"body"}[9]), ",", $message->{"body"}[5], ",", $recdate, ")\n";
record($message->{"body"}[1], convertdate($message->{"body"}[9]), $message->{"body"}[5], $recdate);

### mettre à jour circle.historyindex

# fin



