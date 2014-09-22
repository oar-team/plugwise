#!/usr/bin/perl
use strict;
use warnings;

use Device::Plugwise;

my $TIMEOUT = 60;
my $DATABASE = "plugwise";
my $DBHOST = "localhost";
my $DBUSER = "boutserin";
my $DBPASSWORD = "bouh";

############################# fichier dbutils que j'arrive pas à importer
use DBI;

# (re)initialise la base de données
sub initdb {
  my $dbh = connecttodb();
  $dbh->do("DROP TABLE IF EXISTS record, recordset, circle, monitoredentity, childentity");
  $dbh->do("CREATE TABLE IF NOT EXISTS record (circleaddress VARCHAR(16), date DATETIME, value FLOAT, recdate DATETIME, PRIMARY KEY (circleaddress, date))");
  $dbh->do("CREATE TABLE IF NOT EXISTS monitoredentity (id INTEGER AUTO_INCREMENT UNIQUE PRIMARY KEY, name VARCHAR(20))");
  $dbh->do("CREATE TABLE IF NOT EXISTS circle (name VARCHAR(20), address VARCHAR(16) PRIMARY KEY, historyindex INTEGER DEFAULT -1)");
  $dbh->do("CREATE TABLE IF NOT EXISTS childentity (parent VARCHAR(20), child VARCHAR(20), PRIMARY KEY (parent, child))");
  $dbh->do("CREATE TABLE IF NOT EXISTS recordset (circleaddress VARCHAR(16), monitoredentityid INTEGER, begining DATETIME, end DATETIME DEFAULT null, PRIMARY KEY (circleaddress, monitoredentityid, begining))");
  $dbh->disconnect();
}


# connecte à la base de données et retourne le connecteur
sub connecttodb {
  return DBI->connect("DBI:mysql:database=$DATABASE;host=$DBHOST", $DBUSER, $DBPASSWORD);
#    or die "Cannot connect: " . $DBI::errstr;
}

# enregistre la valeur $value de la date $date pour le circle $circle
sub record {
  my($circle, $date, $value, $recdate) = @_;

#print "record($circle, $date, $value, $recdate)\n";

#  my $test = getrecord($circle, $date);
#  if $test->[0]->{'value'}

  my $dbh = connecttodb();
  $dbh->do("INSERT INTO record (circleaddress, date, value, recdate) VALUES('$circle', $date, $value, $recdate)");
  $dbh->disconnect();
}


# créer un nouveau circle dans la bdd
sub createcircle {
  my $circle = shift(@_);
  my $name = shift(@_);

  if(!defined $name){
    $name = $circle;
  }

  my $dbh = connecttodb();
  $dbh->do("INSERT INTO circle (name, address) VALUES('$name', '$circle')");
  $dbh->disconnect();
}

# créer un nouveau recordset dans la bdd
sub createrecordset {
  my ($circleaddress, $monitoredentityid, $begining) = @_;

# il faut des tests des variables ici, comme dans toutes ces fonctions d'ailleurs

  my $dbh = connecttodb();
  $dbh->do("INSERT INTO recordset (circleaddress, monitoredentityid, begining) VALUES('$circleaddress', $monitoredentityid, $begining)");
  $dbh->disconnect();
}

# créer un nouveau monitoredentity dans la bdd
sub createentity {
  my ($name) = @_;

# il faut des tests des variables ici, comme dans toutes ces fonctions d'ailleurs

  my $dbh = connecttodb();
  $dbh->do("INSERT INTO monitoredentity (name) VALUES('$name')");
  $dbh->disconnect();
}

# envoie un select à mysql et retourne le résultat
# Le résultat est une référence sur un tableau avec sur chaque ligne une référence sur un hash contenant les noms du champ en clefs associées à leur valeur
# une ligne du tableau est une ligne de la bdd, et sur chaque ligne, un hash contient l'ensemble des champs retournées par la requête (le hash donne les colonnes)
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
#print "$circle 's historyindex = ", $$blob[0]{'historyindex'}, "\n";

    return $$blob[0]{'historyindex'};
  }else{
    return -2;
  }
}

# mettre à jour historyindex
sub updatehistoryindex {
  my($circle, $historyindex) = @_;

  my $dbh = connecttodb();
  $dbh->do("UPDATE circle SET historyindex = $historyindex WHERE name = '$circle'");
  $dbh->disconnect();

}

# select all circle de la table circle
sub getcircleslist {
  my $stmt = "SELECT address FROM circle";

  my $blob = selectfromdb($stmt);

  if($blob->[0] =~ /no_data/ ){
    print "No circle found.";
    return 0;
  }else{
    return $blob;
  }


}

#################################

# convertit la date du format plugwise (AAAAMMJJHHMM) au format mysql (AAAA-MM-JJ HH:MM:SS)
sub convertdate {
  my $date = shift(@_);

  if(defined $date){
    $date =~ s/(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/"$1-$2-$3 $4:$5:00"/;
# sale exception ; il faudrait utiliser des fonction perl je pense, ou des vrai trucs mysql
#print "date is $date\n"; 
    if($date =~ /\d\d\d\d-07-(3[2-9]|4\d)/){
      return "0000-00-00 00:00:00";
    }

    return $date;
  }else{
    return "0000-00-00 00:00:00";
  }
}


# imprimer le message reçu du plugwise
sub printmessage {
  my $message = shift(@_);

  print "message is : $message\n";
  print $message->{"schema"}, "\n";
  foreach(@{$message->{"body"}}){
    print $_, "\n";
  }
}


###################################
# Fonctions du programme
###################################

# collecte toutes les valeures non enregistrées dans la bdd pour tous les circles présents dans la bdd
sub collect{

  my $plugwise = Device::Plugwise->new(device => '/dev/ttyUSB0');
#  my $plugwise = Device::Plugwise->new(device => 'localhost:9999');

  # début
  ## il faut faire la liste des circle à récupérer
  my $circles = getcircleslist();
  if($circles->[0] == 0){
    return 0;
  }



  # Pour chaque circle, on récupère les info si on ne les a pas
  for my $refcircle (@$circles){
    print "circle is $$refcircle{'address'}\n";
    my $circle = $$refcircle{'address'};

  ### voir le statut pour récupérer l'index (la dernière valeur enregistrée du circle)
    $plugwise->command('status', $circle);
    my $message = $plugwise->read($TIMEOUT);
#  print $message->{"body"}[6], ":", $message->{"body"}[7], "\n";
    my $lastindex = $message->{"body"}[7];
    print "lastindex = $lastindex\n";
  ### la date doit être convertie
    my $recdate = convertdate($message->{"body"}[9]);
    print "recdate : ", $recdate, "\n";

print "status message :\n";
printmessage($message);

  ### voir la base de données pour connaître le dernier index enregistré (index de la dernière entrée du circle qu'on a enregistré)
    my $dbindex = checkcircle($circle);
#    print "dbindex = $dbindex\n";

  ##### si le circle n'existe pas, l'ajouter ### !!!!!!!!!!!!!!!!!! n'a plus de sens, le circle doit s'ajouter à la main
  #  if($dbindex < -1){
  #   createcircle($circle); 
  #  }

  ### journaliser tous les index à enregistrer


  ### récupérer les index nécessaires (la collecte proprement dite)
    for(my $i = $dbindex+1;$i < $lastindex;$i++){
#$plugwise->command('history', "000D6F0001A5A5FD", $i);
      $plugwise->command('history', $circle, $i);
      $message = $plugwise->read($TIMEOUT);


      if($message !~ /no_data/){
print "history message :\n";
printmessage($message);
  ### enregistrer les index récupérés
        if(convertdate($message->{"body"}[9]) !~ /0000-00-00 00:00:00/){
          record($message->{"body"}[1], convertdate($message->{"body"}[9]), $message->{"body"}[5], $recdate);
        }
      }else {
        print "no_data for index $i\n";
      }
    }

  ### mettre à jour circle.historyindex
    updatehistoryindex($circle, $lastindex-1);
  }

  # fin
}

###################################
# Programme
###################################

# traitement des paramètres
my $function = $ARGV[0];

print "requesting $function\n";
if($function =~ /collect/){
  collect();
  print "values collected\n";
}elsif($function =~ /resetdb/){
  initdb();
  print "DB reseted\n"
}elsif($function =~ /addcircle/){
  my $circleaddress = $ARGV[1];
  my $name = $ARGV[2];
  print "not implemented yet\n";
#  createcircle();
}elsif($function =~ /removecircle/){
  my $address = $ARGV[1];
  print "not implemented yet\n";
#  removecircle();
}else{
  print "this function does not exists\n\n";

  print "to collect data, give 'collect' as argument of the script\n";
  print "to reset the database, give 'resetdb' as argument of the script\n";
  print "circle need to be added in the db manualy for the collect to work\n";
}




